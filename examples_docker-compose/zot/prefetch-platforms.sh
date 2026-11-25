#!/usr/bin/env bash
#
# Fetches the missing platforms for all multi-arch images in the zot mirror areas.
#
# Background: when pulling through the mirror (onDemand), zot only stores the platform the client
# requests (e.g. linux/amd64). Requesting the platform manifests of the other platforms by digest
# makes zot fetch that platform completely (manifest + layers) from upstream.
# The client itself only downloads the manifest (a few KB).
#
# Flow: repos of the mirror areas (MIRRORS) from /v2/_catalog -> tags -> index (manifest list)
# -> for every platform from PLATFORMS that exists in the index but is not stored in zot yet,
# request the platform manifest by digest.
#
# Note: fetching the index by tag makes zot check the tag against upstream (like a normal pull)
# -> changed tags (e.g. latest) are updated as well.
#
# Usage:
#   ./prefetch-platforms.sh [--dry-run] [--verbose] [<repo-filter-regex>]
#
#   --dry-run   only show what would be fetched
#   --verbose   also print complete images / single-arch images
#   <regex>     only repos matching the regular expression (e.g. '^docker.io/library/')
#
# Credentials (user with read access to all mirror areas, e.g. "reader" or a dedicated
# user "prefetch"): environment variables ZOT_USER and ZOT_PASSWORD or ZOT_PASSWORD_FILE.
#
# Cron (hourly):
#   0 * * * *  ZOT_USER=prefetch ZOT_PASSWORD_FILE=/opt/zot/.prefetch-pw /opt/zot/prefetch-platforms.sh >> /var/log/zot-prefetch.log 2>&1
#
# Exit code: 0 = ok, 1 = error for at least one image
#
# Requirements: bash >= 4, curl, jq
#   sudo apt install curl jq
#
set -euo pipefail

# ============================================================================
# Configuration (values can also be overridden by environment variables)
# ============================================================================
ZOT_URL="${ZOT_URL:-https://cr.example.com}"
ZOT_USER="${ZOT_USER:-prefetch}"

# platforms that should be present (os/arch[/variant]; without variant any variant matches)
PLATFORMS="${PLATFORMS:-linux/amd64 linux/arm64 linux/arm/v7}"

# mirror areas (= sync "destination" in config.yaml); own repos are not touched
MIRRORS="${MIRRORS:-docker.io dhi.io quay.io ghcr.io registry.gitlab.com}"

# max. duration per request (zot downloads the complete platform from upstream meanwhile)
TIMEOUT="${TIMEOUT:-1800}"
# ============================================================================

DRY_RUN=false
VERBOSE=false
REPO_FILTER=""

die() { echo "ERROR: $*" >&2; exit 1; }
log() { echo "$*"; }
vlog() { if $VERBOSE; then echo "$*"; fi; }

usage() {
    awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --verbose) VERBOSE=true ;;
        -h|--help) usage ;;
        -*) die "unknown option: $1" ;;
        *) REPO_FILTER="$1" ;;
    esac
    shift
done

command -v curl >/dev/null || die "curl not found (sudo apt install curl)"
command -v jq   >/dev/null || die "jq not found (sudo apt install jq)"

if [[ -z "${ZOT_PASSWORD:-}" && -n "${ZOT_PASSWORD_FILE:-}" ]]; then
    [[ -r "$ZOT_PASSWORD_FILE" ]] || die "password file not readable: $ZOT_PASSWORD_FILE"
    ZOT_PASSWORD=$(<"$ZOT_PASSWORD_FILE")
    ZOT_PASSWORD=${ZOT_PASSWORD%$'\n'}
fi
[[ -n "${ZOT_PASSWORD:-}" ]] || die "set ZOT_PASSWORD or ZOT_PASSWORD_FILE"

ZOT_URL=${ZOT_URL%/}
ACCEPT_INDEX='application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.list.v2+json'
ACCEPT_ANY="$ACCEPT_INDEX,application/vnd.oci.image.manifest.v1+json,application/vnd.docker.distribution.manifest.v2+json"

# credentials via curl config on stdin (not visible in the process list)
CURL_AUTH="user = \"${ZOT_USER}:${ZOT_PASSWORD}\""

# zot_get <path> [curl options...] -> body on stdout, error on HTTP != 200
zot_get() {
    local path=$1; shift
    curl -sS --fail --max-time 120 -K - "$@" "$ZOT_URL$path" <<<"$CURL_AUTH"
}

# zot_fetch_manifest <repo> <digest> <mediaType> -> HTTP code (makes zot sync the platform)
zot_fetch_manifest() {
    curl -sS -o /dev/null -w '%{http_code}' --max-time "$TIMEOUT" -K - \
        -H "Accept: $3" "$ZOT_URL/v2/$1/manifests/$2" <<<"$CURL_AUTH" || true
}

# stored_digests <repo> <tag> -> platform manifests stored in zot (GraphQL of the search extension)
stored_digests() {
    zot_get "/v2/_zot/ext/search" -G --data-urlencode \
        "query={Image(image:\"$1:$2\"){Manifests{Digest}}}" | jq -r '.data.Image.Manifests[]?.Digest // empty'
}

mirror_regex="^($(echo "$MIRRORS" | tr ' ' '\n' | sed 's/\./\\./g' | paste -sd'|' -))/"

catalog=$(zot_get "/v2/_catalog") || die "cannot read catalog ($ZOT_URL, user $ZOT_USER) - check credentials"
repos=$(jq -r '.repositories[]?' <<<"$catalog" | grep -E "$mirror_regex" || true)
if [[ -n "$REPO_FILTER" ]]; then
    repos=$(grep -E "$REPO_FILTER" <<<"$repos" || true)
fi

log "$(date '+%F %T') zot: $ZOT_URL  platforms: $PLATFORMS  $($DRY_RUN && echo '(DRY-RUN)')"

n_repos=0; n_tags=0; n_fetched=0; n_errors=0
for repo in $repos; do
    n_repos=$((n_repos + 1))
    tags=$(zot_get "/v2/$repo/tags/list" | jq -r '.tags[]?') || { log "ERROR $repo: cannot read tags"; n_errors=$((n_errors + 1)); continue; }
    for tag in $tags; do
        n_tags=$((n_tags + 1))
        if ! index=$(zot_get "/v2/$repo/manifests/$tag" -H "Accept: $ACCEPT_ANY"); then
            log "ERROR $repo:$tag: cannot read manifest"; n_errors=$((n_errors + 1)); continue
        fi
        if [[ $(jq -r 'has("manifests")' <<<"$index") != true ]]; then
            vlog "  $repo:$tag  single-arch image, skipped"; continue
        fi
        stored=$(stored_digests "$repo" "$tag" || true)
        missing=()
        for p in $PLATFORMS; do
            IFS=/ read -r os arch variant <<<"$p"
            while read -r digest mtype; do
                [[ -z "$digest" ]] && continue
                grep -qx "$digest" <<<"$stored" && continue
                missing+=("$p $digest $mtype")
            done < <(jq -r --arg os "$os" --arg arch "$arch" --arg variant "${variant:-}" '
                .manifests[] | select(.platform.os == $os and .platform.architecture == $arch
                    and ($variant == "" or (.platform.variant // "") == $variant))
                | "\(.digest) \(.mediaType)"' <<<"$index")
        done
        if [[ ${#missing[@]} -eq 0 ]]; then
            vlog "  $repo:$tag  complete"; continue
        fi
        for m in "${missing[@]}"; do
            read -r p digest mtype <<<"$m"
            if $DRY_RUN; then
                log "  $repo:$tag  $p  would be fetched ($digest)"
                n_fetched=$((n_fetched + 1)); continue
            fi
            code=$(zot_fetch_manifest "$repo" "$digest" "$mtype")
            if [[ "$code" == 200 ]]; then
                log "  $repo:$tag  $p  fetched"
                n_fetched=$((n_fetched + 1))
            else
                log "ERROR $repo:$tag  $p  HTTP $code ($digest)"
                n_errors=$((n_errors + 1))
            fi
        done
    done
done

log "$(date '+%F %T') done: $n_repos repos, $n_tags tags, $n_fetched platforms $($DRY_RUN && echo 'missing' || echo 'fetched'), $n_errors errors"
[[ $n_errors -eq 0 ]]
