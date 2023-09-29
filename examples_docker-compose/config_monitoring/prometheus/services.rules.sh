#!/bin/sh
set -e

# Create example RULES (InstanceDown) for all running Docker Containers !
# more EXAMPLES: https://samber.github.io/awesome-prometheus-alerts/rules.html

DOCKER_CONTAINERS=$(docker ps --format "{{.Names}}" | sort  | tr '\n' ' ')

if [ -n "$DOCKER_CONTAINERS" ]; then

    # create header
    cat > ./services.rules.yml <<EOF
groups:
- name: Services
  rules:
EOF

    # create rules
    for SERVICE in $DOCKER_CONTAINERS; do 
        echo ">> Service: ${SERVICE}"

        # {name="${SERVICE}"} / {name=~".*${SERVICE}.*"} 
        cat >> ./services.rules.yml <<EOF

  - alert: InstanceDown--${SERVICE}
    expr: absent(container_last_seen{name="${SERVICE}"}) or on (name) (time() - container_last_seen{name="${SERVICE}"} > 60)
    for: 5m
    labels:
      severity: critical
      service: ${SERVICE}
    annotations:
      summary: "{{ \$labels.name }} down (for {{ \$value }}s)"
      description: "{{ \$labels.name }} (container #{{ \$labels.container_label_com_docker_compose_container_number }}) on {{ \$labels.instance }} went down {{ \$value }}s ago"
EOF

    done

fi
