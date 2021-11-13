#!/bin/bash

apt-get -yq update
apt-get install -yq \
    ca-certificates \
    curl \
    ntp

# k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${k3s_channel} K3S_TOKEN=${k3s_token} sh -s - \
    --flannel-backend=host-gw \
    --disable local-storage \
    --disable-cloud-controller \
    --disable traefik \
    --disable servicelb \
    --node-taint node-role.kubernetes.io/master:NoSchedule \
    --kubelet-arg 'cloud-provider=external'

# manifestos addons
while ! test -d /var/lib/rancher/k3s/server/manifests; do
    echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
    sleep 1
done

# ccm
kubectl -n kube-system create secret generic hcloud --from-literal=token=${hcloud_token} --from-literal=network=${hcloud_network}
curl -Lo /var/lib/rancher/k3s/server/manifests/hcloud-ccm.yaml https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/download/v1.12.1/ccm-networks.yaml

# csi
kubectl -n kube-system create secret generic hcloud-csi --from-literal=token=${hcloud_token}
curl -Lo /var/lib/rancher/k3s/server/manifests/hcloud-csi.yaml https://raw.githubusercontent.com/hetznercloud/csi-driver/v1.6.0/deploy/kubernetes/hcloud-csi.yml

# additional user_data
${additional_user_data}
