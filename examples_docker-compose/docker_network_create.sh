#!/bin/bash

## INFO: Create Docker Network with IPv4 and IPv6, need IPv6NAT https://docs.docker.com/config/daemon/ipv6/

## Variables
NETWORK_NAME="mynetwork"
NETWORK_SUBNET_IPV4="172.20.0.0/24"
NETWORK_SUBNET_IPV6="fd00:dead:beef::/48"

## docker network create <https://docs.docker.com/engine/reference/commandline/network_create/>
docker network create \
  --driver=bridge \
  --ipv6 \
  --subnet=${NETWORK_SUBNET_IPV6} \
  --subnet=${NETWORK_SUBNET_IPV4} \
  --attachable \
  --label created.by=script \
  ${NETWORK_NAME}
