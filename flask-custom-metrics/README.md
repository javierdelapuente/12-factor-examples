# Basic
```
multipass launch --cpus 4 --disk 50G --memory 4G --name charm-dev 24.04
multipass shell charm-dev

sudo snap install lxd
lxd init --auto
sudo snap install rockcraft --channel latest/edge --classic
sudo snap install charmcraft --channel latest/edge --classic

sudo snap install microk8s --channel 1.31-strict/stable
sudo adduser $USER snap_microk8s
newgrp snap_microk8s
sudo microk8s enable hostpath-storage
sudo microk8s enable registry
# sudo microk8s enable ingress

IPADDR=$(ip -4 -j route get 2.2.2.2 | jq -r '.[] | .prefsrc')
sudo microk8s enable metallb:$IPADDR-$IPADDR

microk8s kubectl rollout status deployments/hostpath-provisioner -n kube-system -w
microk8s kubectl rollout status deployments/coredns -n kube-system -w
microk8s kubectl rollout status daemonset.apps/speaker -n metallb-system -w

sudo snap install juju --channel 3.6/stable
mkdir -p ~/.local/share
juju bootstrap microk8s dev-controller

juju add-model metrics-demo
```

# COS

```
# https://documentation.ubuntu.com/observability/tutorial/installation/getting-started-with-cos-lite/

# curl -L https://raw.githubusercontent.com/canonical/cos-lite-bundle/main/overlays/offers-overlay.yaml -O
# curl -L https://raw.githubusercontent.com/canonical/cos-lite-bundle/main/overlays/storage-small-overlay.yaml -O
# juju deploy cos-lite --trust --overlay ./offers-overlay.yaml --overlay ./storage-small-overlay.yaml

juju deploy cos-lite --trust
```


# The app
```
mkdir flask-hello-world
cd flask-hello-world
```

requirements.txt
```
flask
statsd
```

app.py
```
# initial hello world Flask app

import flask
import statsd

app = flask.Flask(__name__)
statsd_client = statsd.StatsClient('localhost', 9125)

@app.route("/")
def index():
    statsd_client.incr("another_hello_world")
    return "Hello, world!\n"


if __name__ == "__main__":
    app.run()

```

Test it
```
sudo apt-get update && sudo apt-get install python3-venv -y
python3 -m venv .venv
source .venv/bin/activate

flask run -p 8000 &
curl localhost:8000
kill $!
```


# deployment
```
rockcraft init --profile flask-framework
rockcraft pack

rockcraft.skopeo --insecure-policy copy --dest-tls-verify=false oci-archive:flask-hello-world_0.1_$(dpkg --print-architecture).rock   docker://localhost:32000/flask-hello-world:0.1

mkdir charm
cd charm

charmcraft init --profile flask-framework --name flask-hello-world
charmcraft pack
```

The app deployment
```
juju deploy ./flask-hello-world_ubuntu-22.04-$(dpkg --print-architecture).charm \
  flask-hello-world --resource \
  flask-app-image=localhost:32000/flask-hello-world:0.1

juju integrate traefik flask-hello-world

curl http://flask-hello-world --resolve flask-hello-world:80:127.0.0.1

juju integrate grafana flask-hello-world
juju integrate loki flask-hello-world
juju integrate flask-hello-world prometheus

```

## next
juju run traefik/0 show-proxied-endpoints --format=json | jq -r '."traefik/0".results."proxied-endpoints"'  | jq -r  '."flask-hello-world".url'


juju run grafana/0 get-admin-password --format json
juju run grafana/0 get-admin-password --format json | jq -r '."grafana/0".results."admin-password"'
juju run grafana/0 get-admin-password --format json | jq -r '."grafana/0".results."url"'

