# Ansible Integration

This Terraform module includes Ansible integration for executing commands on cluster nodes and managing Kubernetes configuration. The necessary files are automatically generated after applying the Terraform configuration.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Automatically Generated Files](#automatically-generated-files)
3. [Available Playbooks](#available-playbooks)
4. [Running Playbooks](#running-playbooks)
5. [Common Usage Examples](#common-usage-examples)
6. [SSH Config Integration](#ssh-config-integration)

## Prerequisites

### SSH Agent Forwarding

The cluster nodes are only reachable via the gateway node. SSH agent forwarding must be enabled to allow connections to cluster nodes:

```bash
# Ensure ssh-agent is running
eval "$(ssh-agent -s)"

# Add your SSH key to the agent
ssh-add ~/.ssh/id_ed25519
```

**Important:** All SSH connections to cluster nodes require agent forwarding. When using SSH directly, use the `-A` flag:

```bash
ssh -A root@<gateway-ip>
```

When using Ansible, the generated `.ssh/config` automatically enables agent forwarding for connections to cluster nodes.

### Install Ansible Collections

Install required Ansible collections:

```bash
ansible-galaxy collection install -r playbooks/ansible-galaxy.yaml
```

This installs the `kubernetes.core` collection which is required for kubectl-related tasks.

## Automatically Generated Files

After running `terraform apply`, the following files are generated in your working directory:

### `ansible-vars.yaml`

Contains cluster-specific variables used by playbooks:

```yaml
cluster_name: <cluster-name>
gateway_ip: <gateway-ip>
gateway_firewall_k8s_open: <true|false>
```

**Variables:**
- `cluster_name`: Name of your k3s cluster
- `gateway_ip`: Public IP address of the gateway node
- `gateway_firewall_k8s_open`: Whether the Kubernetes API is exposed (default: `false`)

### `.ansible/hosts`

Ansible inventory file with pre-configured host groups:

- **`all_nodes`**: All cluster nodes
- **`all_control_plane_nodes`**: All control plane nodes
- **`all_worker_nodes`**: All worker nodes
- **`gateway`**: Gateway node only
- **`<pool_name>`**: Nodes belonging to a specific pool

The inventory automatically references the `.ssh/config` file for connection settings and disables strict host key checking for convenience when connecting to newly provisioned nodes.

### `.ssh/config`

SSH configuration for easy access to cluster nodes:

- Configures SSH access to all nodes
- Sets up connection parameters
- Includes the `kubeapi` user for API port-forwarding (when `gateway_firewall_k8s_open=false`)

## Available Playbooks

### `playbooks/get-kubeconfig.yaml`

Fetches and configures the Kubernetes kubeconfig from the cluster.

**Features:**
- Waits for cluster to be ready
- Fetches kubeconfig from the first control plane node
- Configures local kubectl with cluster credentials
- Optionally clears `.ssh/known_hosts` entries
- Supports both public and private API modes

**Variables:**
- `ansible_vars_file`: Path to `ansible-vars.yaml` (default: `$PWD/ansible-vars.yaml`)
- `known_hosts_file`: Path to SSH known hosts file (default: `$PWD/.ssh/known_hosts`)
- `clean_known_hosts`: When to clear known hosts (`auto`, `always`, `never`)

## Running Playbooks

### Basic Usage

From your cluster directory:

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible-playbook playbooks/get-kubeconfig.yaml \
  -e "ansible_vars_file=$PWD/ansible-vars.yaml known_hosts_file=$PWD/.ssh/known_hosts"
```

### With Variable Overrides

You can override any playbook variable:

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible-playbook playbooks/get-kubeconfig.yaml \
  -e "ansible_vars_file=$PWD/ansible-vars.yaml known_hosts_file=$PWD/.ssh/known_hosts clean_known_hosts=always"
```

### Understanding the Parameters

- **`ANSIBLE_INVENTORY`**: Points Ansible to the automatically generated inventory
- **`ansible-playbook`**: Command to run the playbook
- **`playbooks/get-kubeconfig.yaml`**: Path to the playbook file
- **`-e`**: Extra variables to pass to the playbook

## Common Usage Examples

### Fetch Kubeconfig

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible-playbook playbooks/get-kubeconfig.yaml \
  -e "ansible_vars_file=$PWD/ansible-vars.yaml known_hosts_file=$PWD/.ssh/known_hosts"
```

After fetching, verify cluster access:

```bash
# If gateway_firewall_k8s_open=true
kubectl get nodes

# If gateway_firewall_k8s_open=false, open SSH tunnel first
./ssh-node kubeapi
kubectl get nodes
```

**Note:** On cluster nodes, use `k3s kubectl` instead of `kubectl`. The playbooks automatically use the correct command.

### Run Commands on All Control Plane Nodes

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible all_control_plane_nodes -a "k3s kubectl cluster-info"
```

### Run Commands on All Worker Nodes

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible all_worker_nodes -a "systemctl status k3s-agent"
```

**Note:** Use `k3s-agent` for worker nodes, not `k3s`.

### Run Commands on Specific Node Pool

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible <pool-name> -a "hostname"
```

### Check System Updates on All Nodes

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible all_nodes -m shell -a "apt list --upgradable"
```

## SSH Config Integration

The generated `.ssh/config` file allows convenient access to cluster nodes using short hostnames:

### SSH Access Patterns

```bash
# Access specific nodes
ssh cluster-system-00
ssh cluster-workers-01

# Access gateway
ssh gateway

# Access via convenience script
./ssh-node <node-name>
```

### Node Names

Node naming convention: `<cluster-name>-<pool-name>-<index>`

Example:
- `cluster-system-00`, `cluster-system-01`, `cluster-system-02` for system pool
- `cluster-workers-00`, `cluster-workers-01` for workers pool

### List Available Nodes

Use the convenience script to see all available nodes:

```bash
./ls-nodes
```

### SCP File Transfer

```bash
# Copy file to node
./scp-node /path/to/file <node-name>:/tmp/

# Copy file from node
./scp-node <node-name>:/var/log/syslog /tmp/
```

## SSH Tunnel for Private Kubernetes API

When `gateway_firewall_k8s_open=false`, the Kubernetes API is not publicly exposed. You must establish an SSH tunnel:

```bash
# Open SSH tunnel
./ssh-node kubeapi

# In another terminal, use kubectl
kubectl get nodes
kubectl cluster-info
```

The tunnel uses the restricted `kubeapi` user on the gateway, which only allows port forwarding for security.

## Troubleshooting

### Playbook Fails with Inventory Error

Ensure the `.ansible/hosts` file exists:

```bash
ls -la .ansible/hosts
```

If missing, run `terraform apply` again.

### Connection Refused

Wait 5-10 minutes after `terraform apply` for cluster initialization.

### Known Hosts Conflicts

Clear the known hosts file:

```bash
rm -f .ssh/known_hosts
```

Or run the playbook with `clean_known_hosts=always`:

```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible-playbook playbooks/get-kubeconfig.yaml \
  -e "ansible_vars_file=$PWD/ansible-vars.yaml known_hosts_file=$PWD/.ssh/known_hosts clean_known_hosts=always"
```

### Kubeconfig Not Working

Verify the kubeconfig context:

```bash
kubectl config current-context
kubectl config view
```

If `gateway_firewall_k8s_open=false`, ensure the SSH tunnel is open:

```bash
./ssh-node kubeapi
```

## Related Documentation

- [Main README](README.md) - General cluster documentation
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Comprehensive troubleshooting guide
- [Ansible Documentation](https://docs.ansible.com/) - Official Ansible docs
- [Kubernetes Collection](https://github.com/ansible-collections/kubernetes.core) - kubernetes.core collection docs
