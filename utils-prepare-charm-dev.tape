# Must be in the machine

Type "sudo snap install lxd"  Sleep 500ms  Enter
Hide Wait@60s /ubuntu@charm-dev:~\$/ Show
Sleep 2s

Type "lxd init --auto"  Sleep 500ms  Enter
Hide Wait@60s /ubuntu@charm-dev:~\$/ Show
Sleep 2s

Type "sudo snap install rockcraft --classic"  Sleep 500ms Enter
Hide Wait@60s /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type "sudo snap install charmcraft --classic"  Sleep 500ms Enter
Hide Wait@60s /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type "sudo snap install microk8s --channel 1.31-strict/stable"  Sleep 500ms  Enter
Hide Wait@180s /ubuntu@charm-dev:~\$/ Show
Sleep 10s

Type "sudo microk8s.status --wait-ready"  Sleep 500ms  Enter
Hide Wait@240s /ubuntu@charm-dev:~\$/ Show
Sleep 10s

Type "sudo adduser $USER snap_microk8s"  Sleep 500ms Enter
Hide Wait /ubuntu@charm-dev:~\$/ Show

Type "newgrp snap_microk8s"  Sleep 500ms Enter
Hide Wait /ubuntu@charm-dev:~\$/ Show

Type "sudo microk8s.enable registry"  Sleep 500ms  Enter
Hide Wait /ubuntu@charm-dev:~\$/ Show
Sleep 2s

# Type "sudo microk8s.enable ingress"  Sleep 500ms  Enter
# Hide Wait /ubuntu@charm-dev:~\$/ Show
# Sleep 5s

Type "IPADDR=$(ip -4 -j route get 2.2.2.2 | jq -r '.[] | .prefsrc')"  Sleep 500ms  Enter
Hide Wait /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type `sudo microk8s enable metallb:$IPADDR-$IPADDR`  Sleep 500ms  Enter
Hide Wait@180s /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type `microk8s kubectl rollout status daemonset.apps/speaker -n metallb-system -w`  Sleep 500ms  Enter
Hide Wait@180s /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type "sudo snap alias microk8s.kubectl kubectl"  Sleep 500ms  Enter
Hide Wait /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type `sudo snap install juju --channel 3.6/stable`  Sleep 500ms  Enter
Hide Wait@180s /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type "mkdir -p ~/.local/share"  Sleep 500ms  Enter
Hide Wait@180s /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type "juju bootstrap microk8s dev-controller"  Sleep 500ms  Enter
Hide Wait@360s /ubuntu@charm-dev:~\$/ Show
Sleep 5s
