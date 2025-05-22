#!/bin/bash

set -euxo pipefail

vhs flask-custom-metrics.tape

curl "$(multipass exec charm-dev -- juju run traefik/0 show-proxied-endpoints --format=json | jq -r '."traefik/0".results."proxied-endpoints"' | jq -r '."flask-custom-metrics".url')"

multipass exec charm-dev -- juju run traefik/0 show-proxied-endpoints --format=json | jq -r '."traefik/0".results."proxied-endpoints"' | jq '.'
multipass exec charm-dev -- juju run grafana/0 get-admin-password

