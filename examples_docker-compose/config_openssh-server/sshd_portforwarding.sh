#!/bin/sh
set -eu
SSHD_CONF_FILE="/etc/ssh/sshd_config"
echo ">> Enable PortForwarding"
sed -i "s|AllowTcpForwarding.*|AllowTcpForwarding yes|g" ${SSHD_CONF_FILE}
sed -i "s|GatewayPorts.*|GatewayPorts yes|g" ${SSHD_CONF_FILE}