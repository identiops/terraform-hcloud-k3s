#!/bin/bash
# Initialization steps, see https://github.com/hetznercloud/hcloud-cloud-controller-manager

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

curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${k3s_channel} INSTALL_K3S_VERSION=${k3s_version} K3S_TOKEN=${k3s_token} sh -s - \
    server \
    --cluster-init \
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

# manifestos addons
while ! test -d /var/lib/rancher/k3s/server/manifests; do
    echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
    sleep 1
done

# cni
## 4. Deploy the flannel CNI plugin
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

## 5. Patch the flannel deployment to tolerate the uninitialized taint
# kubectl -n kube-system patch ds kube-flannel-ds --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'

## 4-5. Deploy calico
### calico: https://projectcalico.docs.tigera.io/getting-started/kubernetes/k3s/multi-node-install
### Use eBPF for higher throughput, and comes with limitations: https://projectcalico.docs.tigera.io/maintenance/enabling-bpf
### TODO eBPF needs configuration
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
# kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
# Customized ip pool (custom-resources.yaml):
kubectl apply -f - <<EOF
# This section includes base Calico installation configuration.
# For more information, see: https://projectcalico.docs.tigera.io/v3.22/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: ${cluster_cidr_network}
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
    nodeAddressAutodetectionV4:
      firstFound: true
    nodeAddressAutodetectionV6:
      firstFound: true
---
# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/v3.22/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF

# ccm
## 6. Create a secret containing your Hetzner Cloud API token
kubectl -n kube-system create secret generic hcloud --from-literal=token=${hcloud_token} --from-literal=network=${hcloud_network}

## 7. Deploy the hcloud-cloud-controller-manager
[ "${hcloud_ccm_driver_install}" = "true" ] && curl -Lo /var/lib/rancher/k3s/server/manifests/hcloud-ccm.yaml https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/download/v${hcloud_ccm_driver_version}/ccm-networks.yaml

# csi
kubectl -n kube-system create secret generic hcloud-csi --from-literal=token=${hcloud_token}

[ "${hcloud_csi_driver_install}" = "true" ] && curl -Lo /var/lib/rancher/k3s/server/manifests/hcloud-csi.yaml https://raw.githubusercontent.com/hetznercloud/csi-driver/v${hcloud_csi_driver_version}/deploy/kubernetes/hcloud-csi.yml

# additional user_data
${additional_user_data}
