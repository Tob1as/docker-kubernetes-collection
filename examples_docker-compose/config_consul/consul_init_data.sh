#!/bin/sh
set -eu

docker exec -it consul-server1 consul join -wan consul-server0
curl http://127.0.0.1:8500/v1/catalog/datacenters
curl -X PUT -d 'myvalue' localhost:8500/v1/kv/mykey
curl -X PUT -d 'myvalue2' localhost:8500/v1/kv/mykey2
curl -X PUT -d 'myvalue2' localhost:8500/v1/kv/mykey2?dc=dc2
