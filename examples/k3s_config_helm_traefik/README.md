# k3s_config_helm_traefik

Install required Ansible collections:

```bash
ansible-galaxy collection install -r ../../playbooks/ansible-galaxy.yaml
```

Run the kubeconfig playbook from this example directory:

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible-playbook ../../playbooks/get-kubeconfig.yaml \
  -e "ansible_vars_file=$PWD/ansible-vars.yaml known_hosts_file=$PWD/.ssh/known_hosts"
```

If `gateway_firewall_k8s_open = false`, open an SSH tunnel before `kubectl`:

```bash
./ssh-node kubeapi
```

## Configure Traefik LoadBalancer (HCCM)

After the cluster is running and kubeconfig is available locally, create a
`HelmChartConfig` for the bundled Traefik chart so HCCM can provision a
Hetzner LoadBalancer.

Use the same location as `default_location` from `main.tf` (currently `fsn1`):

```bash
LOCATION="fsn1"

kubectl apply -f - <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    service:
      annotations:
        load-balancer.hetzner.cloud/name: "helm-traefik-ingress"
        load-balancer.hetzner.cloud/protocol: "tcp"
        load-balancer.hetzner.cloud/location: "${LOCATION}"
        load-balancer.hetzner.cloud/use-private-ip: "true"
        load-balancer.hetzner.cloud/type: "lb11"
EOF
```

Verify:

```bash
kubectl -n kube-system get svc traefik -o wide
kubectl -n kube-system logs deploy/hcloud-cloud-controller-manager --tail=100
```

## Teardown and cleanup

If `terraform destroy` hangs, the CCM-managed Hetzner LoadBalancer may still be
present and block cleanup.

List and delete the Traefik load balancer, then run destroy again:

```bash
hcloud load-balancer list
hcloud load-balancer delete helm-traefik-ingress

terraform destroy -auto-approve
```
