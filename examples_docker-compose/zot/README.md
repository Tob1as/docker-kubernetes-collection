# zot: pull-through cache for several registries + own container registry (cr)

Example setup of [zot](https://zotregistry.dev/) ([GitHub](https://github.com/project-zot/zot)) as **one** container that is

- a **pull-through cache (mirror)** for Docker Hub, Docker Hardened Images (dhi.io), quay.io, ghcr.io and registry.gitlab.com,
- an **own registry** for your images,
- with **Web UI**, **CVE scanning** (Trivy), **Prometheus metrics**, **users/permissions** and **automatic cleanup** (retention).

Tested with zot v2.1.23 (`ghcr.io/project-zot/zot:latest`), behind Traefik.

## Files

| File | Content |
|---|---|
| [docker-compose.yml](docker-compose.yml) | Docker Compose (Traefik, host `cr.example.com`) |
| [config.yaml](config.yaml) | zot configuration (YAML instead of JSON, so it can contain comments) |
| [config.json](config.json) | same configuration as JSON (example, without comments/commented-out parts) |
| [credentials.example.json](credentials.example.json) | template for upstream credentials → `credentials.json` |
| [prefetch-platforms.sh](prefetch-platforms.sh) | fetches missing platforms (arm64, arm/v7, …) for mirror images (cron) |
| [cve-scan-all.sh](cve-scan-all.sh) | triggers the CVE scan for all repos/tags and prints a summary |
| [docker-compose.local.yml](docker-compose.local.yml) | Compose override for a local test instance (port 5080, no Traefik, see below) |
| `credentials.json`, `htpasswd` | upstream credentials and users (in [.gitignore](.gitignore), create them yourself) |

## Setup

```sh
cp credentials.example.json credentials.json      # Docker Hub user + PAT for registry-1.docker.io and dhi.io
docker run --rm httpd:2.4-alpine htpasswd -Bbn admin      '<pw>' >  htpasswd
docker run --rm httpd:2.4-alpine htpasswd -Bbn developer  '<pw>' >> htpasswd
docker run --rm httpd:2.4-alpine htpasswd -Bbn ci         '<pw>' >> htpasswd
docker run --rm httpd:2.4-alpine htpasswd -Bbn reader     '<pw>' >> htpasswd
docker run --rm httpd:2.4-alpine htpasswd -Bbn prometheus '<pw>' >> htpasswd
docker run --rm httpd:2.4-alpine htpasswd -Bbn prefetch   '<pw>' >> htpasswd
docker compose up -d
```

- Instead of `httpd:2.4-alpine` (~67 MB) you can also use the smaller image `tobi312/tools:htpasswd` (~9 MB, only Apache's `htpasswd`):
  `docker run --rm tobi312/tools:htpasswd -Bbn <username> <password> >> htpasswd`
- Replace `cr.example.com` with your hostname (Traefik labels in `docker-compose.yml`), DNS entry and TLS certificate required.
- The compose file uses an external Docker network `mynetwork` shared with Traefik → adjust to your Traefik network
  (or remove the labels/network and publish port 5000 directly).
- `credentials.json` **and** `htpasswd` must exist before the first start (otherwise Docker creates a directory and zot does not start).
- Changes to `htpasswd` → restart zot.
- Check the config: `docker run --rm -v ./config.yaml:/etc/zot/config.yaml:ro ghcr.io/project-zot/zot:latest verify /etc/zot/config.yaml`
- The healthcheck calls `/usr/local/bin/zot-linux-amd64` → change to `zot-linux-arm64` on ARM hosts
  (the image is distroless, no shell/wget; there is no `/usr/bin/zot`).

## Config: YAML or JSON

zot reads both formats (`serve /etc/zot/config.yaml` or `serve /etc/zot/config.json`). [config.yaml](config.yaml) is the
leading file (comments, commented-out options); [config.json](config.json) has the same content as JSON.
Convert with [yq](https://github.com/mikefarah/yq) (both directions tested, result accepted by `zot verify`):

```sh
yq -o json config.yaml > config.json              # YAML -> JSON (comments are lost)
yq -p json -o yaml config.json > config.yaml      # JSON -> YAML (without comments!)

# without installation, via Docker
docker run --rm -v "$PWD:/workdir" mikefarah/yq -o json config.yaml > config.json

# alternatively Python (pyyaml)
python3 -c 'import sys,yaml,json; json.dump(yaml.safe_load(open("config.yaml")), sys.stdout, indent=2)' > config.json
```

- After changing `config.yaml`, regenerate the JSON file (it is not updated automatically).
- yq writes lists one item per line instead of `["a", "b"]` → same content.
- Windows PowerShell 5.1: `>` writes UTF-16 → zot cannot read the file. Use `cmd /c "... > config.json"` or WSL/Linux.

## Image names

| Area | Name |
|---|---|
| Mirror | `cr.example.com/<upstream>/<repo>:<tag>` |
| Own registry | `cr.example.com/(<namespace>/)<repo>:<tag>` |

```sh
docker pull cr.example.com/docker.io/library/alpine:latest   # official images need "library/"
docker pull cr.example.com/dhi.io/alpine-base:3.22
docker pull cr.example.com/quay.io/prometheus/prometheus:latest
docker pull cr.example.com/ghcr.io/project-zot/zot:latest
docker pull cr.example.com/registry.gitlab.com/<group>/<project>:<tag>
docker push cr.example.com/myteam/myapp:1.0
```

- `http.compat: [docker2s2]` → Docker images keep their media types, **digests are identical to upstream**.
- Own repos never ask upstream (pulling a non-existing own repo → 404).

## Users and permissions (`http.accessControl`)

| Area | anonymous | any login (`reader`, …) | group `developers` (`developer`, `ci`) | group `admins` (`admin`) |
|---|---|---|---|---|
| Own registry (`**`) | – | pull | pull, push, overwrite, delete | everything |
| `docker.io/**`, `dhi.io/**` (use your Docker account → also private images) | – | pull | pull | everything |
| `quay.io/**`, `ghcr.io/**`, `registry.gitlab.com/**` | pull | pull | pull | everything |
| `/metrics` | – | – | – | `admin` (+ `prometheus`) |

- The rule with the **longest matching path** applies; `**` = everything that is not a mirror path.
- **Without the read-only entries for the mirror paths, anyone with push rights could push into them (cache poisoning!).**
  zot without any `accessControl` even allows anonymous push.
- More developer/CI accounts: create in `htpasswd` and add to `accessControl.groups.developers.users`.
- More admins: add to `accessControl.groups.admins.users` (`adminPolicy` uses the group).
  `/metrics` does not support groups → add users directly to `accessControl.metrics.users`.
- Every user in `htpasswd` (also `prometheus`, `prefetch`) gets `defaultPolicy` → can pull. zot has no deny rules,
  so a "metrics only" user is not possible (alternative: `metrics.anonymousPolicy: [read]` without a user).

> **Docker CLI always needs `docker login`**, also for the anonymous mirrors quay/ghcr/gitlab.
> zot intentionally answers the Docker client on `/v2/` with 401 if anonymous and login-only areas are mixed,
> otherwise Docker would never send credentials (cannot be disabled). Other clients (containerd/Kubernetes, podman, skopeo, crane)
> can use the anonymous mirrors without login.

## Adding a mirror (checklist)

1. `config.yaml` → `extensions.sync.registries`: entry with `urls`, `onDemand: true`, `content: [{prefix: "**", destination: /<name>}]`.
2. `config.yaml` → `http.accessControl.repositories`: **`"<name>/**"` with `defaultPolicy: [read]`** (+ `anonymousPolicy: [read]` if public).
   **Without this entry the mirror path is writable for developers!**
3. If upstream login is required: `credentials.json` → key = host of the URL (e.g. `registry-1.docker.io`).
   Wrong credentials → no anonymous fallback.
4. `config.yaml` → `storage.retention.policies`: add `"<name>/**"` to the mirror policy (3 months), otherwise `**` (12 months) applies.
5. `prefetch-platforms.sh`: add `<name>` to `MIRRORS`.

## Freshness of mirror images (e.g. `latest`)

- Images are fetched on the first pull (`onDemand`).
- A **tag is checked against upstream on every pull** → a new upstream version is fetched and served.
  If upstream is unreachable, the stored version is served. Pulls by digest are not checked.
- Optional `manifestCheckInterval: 1h` per registry: only check once per hour per tag (fewer requests, up to 1 h outdated).
- **Periodic sync (`pollInterval`) does not work with Docker Hub & co.**: zot first lists all repos of the upstream (`/v2/_catalog`),
  which these registries deny (`failed to list repositories ... unauthorized`).
- With on-demand only the requested platform is cached (warnings "skipping missing manifest blob in image index" are normal).
  There is no option to fetch all platforms on pull (`platforms` is ignored for on-demand) → see next section.

## Fetching more platforms ([prefetch-platforms.sh](prefetch-platforms.sh))

If e.g. only `linux/amd64` was pulled, the script fetches the other platforms (default: `linux/amd64 linux/arm64 linux/arm/v7`)
for all images in the mirror areas. It requests the platform manifests by digest from zot; zot then fetches this platform
completely (manifest + layers) from upstream, the script itself only downloads a few KB.
Own repos are not touched, single-arch images are skipped, platforms that do not exist upstream are ignored.

```sh
# Requirements: bash, curl, jq; user with read access (e.g. "prefetch" in htpasswd)
echo '<pw>' > /opt/zot/.prefetch-pw && chmod 600 /opt/zot/.prefetch-pw
ZOT_USER=prefetch ZOT_PASSWORD_FILE=/opt/zot/.prefetch-pw ./prefetch-platforms.sh --dry-run   # only show
ZOT_USER=prefetch ZOT_PASSWORD_FILE=/opt/zot/.prefetch-pw ./prefetch-platforms.sh             # fetch
ZOT_USER=prefetch ZOT_PASSWORD_FILE=/opt/zot/.prefetch-pw ./prefetch-platforms.sh '^docker.io/library/'   # only some repos

# Cron (hourly)
0 * * * *  ZOT_USER=prefetch ZOT_PASSWORD_FILE=/opt/zot/.prefetch-pw /opt/zot/prefetch-platforms.sh >> /var/log/zot-prefetch.log 2>&1
```

- Settings via environment variables: `ZOT_URL` (default `https://cr.example.com`), `PLATFORMS`,
  `MIRRORS` (must match the sync `destination`s), `TIMEOUT`.
- Fetching the index by tag checks the tag against upstream (like a pull) → changed tags (e.g. `latest`) are updated
  and their new platforms are fetched on the next run.
- Exit code 1 on errors (e.g. wrong credentials, upstream unreachable).

## Deleting old images (retention, `storage.retention`)

zot does this itself (no script needed). A tag is deleted if it was **neither pulled nor pushed** within the period
(mirror: pushed = fetched/updated from upstream). Runs with every GC run (default hourly), blobs are removed by GC afterwards.

| Area | kept since last pull/push | Setting |
|---|---|---|
| Mirrors (`docker.io/**`, `dhi.io/**`, `quay.io/**`, `ghcr.io/**`, `registry.gitlab.com/**`) | 3 months | `2160h` |
| Own registry (`**`) | 12 months, the 3 newest tags per repo always | `8760h`, `mostRecentlyPushedCount: 3` |

- Deleted mirror images are fetched again from upstream on the next pull.
- **Only real downloads count as pull**: if a client already has the image locally, `docker pull` (or containerd/Kubernetes)
  only sends a HEAD request → not counted (tested). An own image used daily from the node cache still expires
  12 months after the push → therefore the 3 newest tags per repo are always kept (`mostRecentlyPushedCount`);
  exclude other important tags (see below).
- `mostRecentlyPulledCount` keeps the most **recently** downloaded tags (not the most popular ones; the download count is
  not used by retention). If fewer tags were ever pulled, zot fills up with unpulled tags sorted by name.
- Durations only in hours (Go duration, no `d`/months). Regex in `patterns` is **not anchored** → use `^...$`.
- Rules: per repo the **first** policy whose glob matches applies; per tag the **first** `keepTags` entry whose `patterns`
  match; within an entry a tag is kept if **any** rule matches. Repos without policy are never touched.
- Check without deleting: `dryRun: true`, then search the log:
  `docker logs zot-registry 2>&1 | grep '"module":"retention"' | grep '"decision":"delete"'`
- `zot verify` warns "retention policy can overlap with the sync config" → intended.

**Excluding `image:tag`** (own registry): create a separate policy per repo **before** `**`. Only the first matching
policy applies, so repeat the 12 month rule there:

```yaml
      - repositories: ["myteam/myapp"]          # glob, e.g. also "myteam/**"
        deleteReferrers: true
        deleteUntagged: true
        keepTags:
          - patterns: ['^1\.0$', '^stable$']     # these tags: never deleted
          - pulledWithin: 8760h                 # all other tags: 12 months
            pushedWithin: 8760h
            mostRecentlyPushedCount: 3
```

Tested (with minutes instead of months): mirror image and non-excluded own tags were deleted, the excluded tag was kept,
tags fetched again from upstream start at 0 again.

## Web UI

`https://cr.example.com/` – login with the htpasswd users. Shows repos, tags, platforms, layers, CVEs and signatures;
everyone only sees what they may read (anonymous: quay/ghcr/gitlab).
Star/bookmark and delete (trash icon per tag under "Tags History") are only available when logged in. As anonymous read is allowed,
the UI also lets guests in ("Continue as guest", expired session after 2 h) → then these functions are missing; log in again via `/login`.
Therefore Traefik routes the whole host (not only `/v2`). Traefik basic auth is **not** used with zot (zot would not know the user).

## CVE scanning (Trivy)

- `extensions.search.cve`: Trivy DB update every `updateInterval` (24h, minimum 2h), stored in `/var/lib/registry/_trivy`.
- DB source: `mirror.gcr.io/aquasec/trivy-db` and `mirror.gcr.io/aquasec/trivy-java-db` (Trivy's default, no pull limit).
  zot allows only **one** source (no fallback list). Alternatives (switch manually):
  `public.ecr.aws/aquasecurity/trivy-db` / `-java-db` or `ghcr.io/aquasecurity/trivy-db` / `-java-db` (zot's default, pull limits).
- First start: DB download approx. 140 MB, 2–4 minutes.
- **Automatic scan:** new/unscanned images every 15 minutes in the background, all again after each DB update.
- Immediate scan: open the image in the UI or use GraphQL `CVEListForImage`, for all images:
  ```sh
  ZOT_URL=https://cr.example.com ZOT_USER=reader ZOT_PASSWORD=<pw> ./cve-scan-all.sh ['<repo-regex>']
  ```
- Results: UI or GraphQL API `/v2/_zot/ext/search` (`ImageList` only shows cached results).

## Metrics (Prometheus)

`https://cr.example.com/metrics` – only for the users in `http.accessControl.metrics.users`
(`prometheus`, `admin`). Without login → 401, other users → 403. (Anonymous scraping would be `metrics.anonymousPolicy: [read]`.)

```yaml
# prometheus.yml
scrape_configs:
  - job_name: zot
    scheme: https
    metrics_path: /metrics
    basic_auth:
      username: prometheus
      password: <pw>
    static_configs:
      - targets: ['cr.example.com']
```

## Clients

- **Docker Engine:** `registry-mirrors` in `/etc/docker/daemon.json` only applies to **Docker Hub** and cannot send **credentials**
  → not usable with authentication. Pull images explicitly via the mirror name instead (after `docker login`).
- **containerd / Kubernetes:** transparent mirrors for any registry via `hosts.toml`, e.g.:
  ```toml
  # /etc/containerd/certs.d/quay.io/hosts.toml
  [host."https://cr.example.com/v2/quay.io"]
    capabilities = ["pull", "resolve"]
    override_path = true
  ```
  For login-only areas additionally configure credentials in containerd or use an `imagePullSecret`.

## Local test instance ([docker-compose.local.yml](docker-compose.local.yml))

Override for `docker-compose.yml`: same `config.yaml`, but port `127.0.0.1:5080`, without Traefik (`traefik.enable=false`),
own project name/volume/network (`zot-local`), no restart. Uses the `credentials.json` and `htpasswd` of this directory,
e.g. without upstream credentials (`{}` → Docker Hub anonymous, dhi.io not usable) and with test users:

```sh
echo '{}' > credentials.json
for u in admin developer ci reader prometheus prefetch; do
  docker run --rm httpd:2.4-alpine htpasswd -Bbn "$u" passw0rd
done > htpasswd

docker compose -f docker-compose.yml -f docker-compose.local.yml up -d     # UI: http://localhost:5080
docker compose -f docker-compose.yml -f docker-compose.local.yml down -v   # remove incl. data
```

| User | Password | Role |
|---|---|---|
| admin | passw0rd | everything (group admins) |
| developer | passw0rd | group developers (push) |
| ci | passw0rd | group developers (push) |
| reader | passw0rd | read only |
| prometheus | passw0rd | /metrics + read (like every login, `defaultPolicy`) |
| prefetch | passw0rd | read only (for prefetch-platforms.sh) |

Fill it (example):
```sh
echo passw0rd | docker login 127.0.0.1:5080 -u admin --password-stdin
docker pull 127.0.0.1:5080/docker.io/library/nginx:1.25
docker pull 127.0.0.1:5080/quay.io/prometheus/node-exporter:v1.5.0
echo passw0rd | docker login 127.0.0.1:5080 -u developer --password-stdin
docker tag 127.0.0.1:5080/docker.io/library/nginx:1.25 127.0.0.1:5080/demo/webapp:1.0
docker push 127.0.0.1:5080/demo/webapp:1.0
ZOT_URL=http://127.0.0.1:5080 ZOT_USER=admin ZOT_PASSWORD=passw0rd sh cve-scan-all.sh                 # CVE scan + summary
ZOT_URL=http://127.0.0.1:5080 ZOT_USER=prefetch ZOT_PASSWORD=passw0rd bash prefetch-platforms.sh     # fetch arm64/arm-v7
```
