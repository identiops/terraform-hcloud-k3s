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
