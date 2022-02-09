#!/bin/bash
# Initialization steps, see https://github.com/hetznercloud/hcloud-cloud-controller-manager

set -e

apt-get -yq update
apt-get install -yq \
    ca-certificates \
    curl \
    ntp \
    jq

# k3s
## 1-3. Now the cluster master can be initialized
# CNI configuration option for flanell:
#     --flannel-backend=host-gw \

curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${k3s_channel} INSTALL_K3S_VERSION=${k3s_version} K3S_URL=https://${control_plane_master_internal_ipv4}:6443 K3S_TOKEN=${k3s_token} sh -s - \
    server \
    --flannel-backend=none \
    --disable-network-policy \
    --cluster-cidr=${cluster_cidr_network} \
    --service-cidr=${service_cidr_network} \
    --node-ip="$(ip -4 -j a s dev ens10 | jq '.[0].addr_info[0].local' -r)" \
    --node-external-ip="$(ip -4 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r),$(ip -6 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r)" \
    --disable local-storage \
    --disable-cloud-controller \
    --disable traefik \
    --disable servicelb \
    ${control_plane_k3s_addtional_options} --kubelet-arg 'cloud-provider=external'

# additional user_data
${additional_user_data}
