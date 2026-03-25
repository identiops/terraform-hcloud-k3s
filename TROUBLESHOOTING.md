# Troubleshooting Guide

This guide covers common issues and troubleshooting steps for the Terraform HCloud K3S cluster.

## Table of Contents

1. [SSH Connection Issues](#ssh-connection-issues)
2. [Ansible Connection Issues](#ansible-connection-issues)
3. [Cluster Initialization](#cluster-initialization)
4. [Kubernetes API Access](#kubernetes-api-access)
5. [Common Errors](#common-errors)

## SSH Connection Issues

### Cluster nodes are not reachable

Cluster nodes are only reachable via the gateway node using SSH agent forwarding.

**Symptoms:**
- `ssh node-name` hangs or times out
- Connection refused or timeout errors

**Solution:**

1. **Enable SSH agent forwarding:**
   ```bash
   # Ensure ssh-agent is running
   eval "$(ssh-agent -s)"

   # Add your SSH key to agent
   ssh-add ~/.ssh/id_ed25519
   ```

2. **Use `-A` flag for SSH:**
   ```bash
   ssh -A root@<gateway-ip>
   ```

3. **Connect to gateway first, then to nodes:**
   ```bash
   # Connect to gateway with agent forwarding
   ssh -A root@46.224.99.171

   # Then connect to nodes from gateway
   ssh 10.0.1.2
   ```

### Port 6443 in use

**Symptoms:**
- `bind [127.0.0.1]:6443: Address already in use`
- Cannot establish Kubernetes API tunnel

**Solution:**
```bash
# Kill existing SSH tunnel
pkill -f "ssh.*6443"

# Try again
./ssh-node kubeapi
```

### Known hosts conflict

**Symptoms:**
- `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED`
- SSH connection blocked due to changed host key

**Solution:**
```bash
# Remove specific host from known_hosts
ssh-keygen -f .ssh/known_hosts -R <gateway-ip>

# Or clear entire file (less secure)
rm -f .ssh/known_hosts
```

## Ansible Connection Issues

### Ansible cannot connect to cluster nodes

**Symptoms:**
- `UNREACHABLE! => Failed to connect to the host via ssh`
- Connection timeout during banner exchange

**Solution:**

1. **Verify SSH agent forwarding is enabled:**
   ```bash
   # Check if ssh-agent is running
   pgrep -a ssh-agent

   # Add your SSH key
   ssh-add ~/.ssh/id_ed25519
   ```

2. **Check if generated files exist:**
   ```bash
   ls -la .ansible/hosts ansible-vars.yaml .ssh/config
   ```

3. **Verify SSH connection to gateway:**
   ```bash
   ssh -A root@<gateway-ip> 'hostname && uptime'
   ```

4. **Verify connection from gateway to nodes:**
   ```bash
   ssh -A root@<gateway-ip> 'ping -c 2 10.0.1.2'
   ssh -A root@<gateway-ip> 'ssh -o StrictHostKeyChecking=no 10.0.1.2 hostname'
   ```

5. **Test Ansible connectivity:**
   ```bash
   ANSIBLE_INVENTORY="$PWD/.ansible/hosts" ansible all_control_plane_nodes -m ping
   ```

6. **Check firewall settings on gateway:**
   ```bash
   ssh -A root@<gateway-ip> 'ufw status'
   ssh -A root@<gateway-ip> 'iptables -L -t nat'
   ```

### Playbook fails with "kubectl: command not found"

**Symptoms:**
- `bash: line 1: kubectl: command not found`
- Playbook cannot execute kubectl commands

**Solution:**

Use `k3s kubectl` instead of `kubectl` on cluster nodes. The playbooks are updated to use the correct command.

**Verify:**
```bash
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" ansible all_control_plane_nodes -a "which k3s"
```

## Cluster Initialization

### SSH to cluster hangs

**Symptoms:**
- SSH connection hangs indefinitely
- No response from cluster nodes

**Solution:**

Wait for cluster initialization (~5 minutes after `terraform apply`).

**Check status:**
```bash
# Check cloud-init status
ssh -A root@<gateway-ip> 'cloud-init status'

# Check if k3s is running
ssh -A root@<gateway-ip> 'ssh 10.0.1.2 "systemctl status k3s"'
```

### Cluster not ready after initialization

**Symptoms:**
- `kubectl cluster-info` fails
- Nodes not showing up

**Solution:**

1. **Wait for cloud-init to complete:**
   ```bash
   ssh -A root@<gateway-ip> 'cloud-init status'
   # Expected: status: done
   ```

2. **Check network connectivity:**
   ```bash
   # Verify default route
   ssh -A root@<gateway-ip> 'ssh 10.0.1.2 "ip r s"'

   # Verify internet connectivity
   ssh -A root@<gateway-ip> 'ssh 10.0.1.2 "ping -c 2 1.1.1.1"'
   ```

3. **Check k3s service status:**
   ```bash
   ssh -A root@<gateway-ip> 'ssh 10.0.1.2 "systemctl status k3s"'
   ```

4. **Check k3s logs:**
   ```bash
   ssh -A root@<gateway-ip> 'ssh 10.0.1.2 "journalctl -u k3s -n 50"'
   ```

## Kubernetes API Access

### Cannot access Kubernetes API

**Symptoms:**
- `kubectl get nodes` fails
- Connection refused or timeout

**Solution:**

Check if `gateway_firewall_k8s_open` is set:

```bash
# Check ansible-vars.yaml
cat ansible-vars.yaml
# If gateway_firewall_k8s_open: false, you need SSH tunnel
```

**If gateway_firewall_k8s_open = false:**

1. **Open SSH tunnel:**
   ```bash
   ./ssh-node kubeapi
   ```

2. **In another terminal, use kubectl:**
   ```bash
   kubectl get nodes
   kubectl cluster-info
   ```

**If gateway_firewall_k8s_open = true:**

1. **Verify API port is accessible:**
   ```bash
   telnet <gateway-ip> 6443
   ```

2. **Check kubeconfig:**
   ```bash
   kubectl config view
   kubectl config current-context
   ```

3. **Use setkubeconfig script:**
   ```bash
   ./setkubeconfig
   ```

## Common Errors

### "Permission denied (publickey)"

**Symptoms:**
- `Permission denied (publickey)`
- SSH authentication fails

**Solution:**

1. **Check if SSH key is added to agent:**
   ```bash
   ssh-add -l
   ```

2. **Add SSH key to agent:**
   ```bash
   ssh-add ~/.ssh/id_ed25519
   ```

3. **Verify SSH key is configured in Terraform:**
   ```bash
   grep ssh_keys main.tf
   ```

### "Connection refused"

**Symptoms:**
- `Connection refused` when connecting to cluster
- SSH service not reachable

**Solution:**

1. **Verify node status in Hetzner Console:**
   - Check if nodes are running
   - Check firewall rules

2. **Check cloud-init status:**
   ```bash
   ssh -A root@<gateway-ip> 'cloud-init status'
   ```

3. **Verify firewall:**
   ```bash
   ssh -A root@<gateway-ip> 'ufw status'
   ```

### "ansible_ssh_common_args: command not found"

**Symptoms:**
- Ansible complains about `ansible_ssh_common_args`
- Cannot use custom SSH arguments

**Solution:**

Ensure you're using Ansible 2.10 or later:

```bash
ansible --version
# Should be 2.10 or higher
```

## Quick Reference

### Essential Commands

```bash
# Start SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Connect to gateway with agent forwarding
ssh -A root@<gateway-ip>

# Kill SSH tunnel on port 6443
pkill -f "ssh.*6443"

# Remove known hosts entry
ssh-keygen -f .ssh/known_hosts -R <gateway-ip>

# Test Ansible connectivity
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" ansible all_control_plane_nodes -m ping

# Run kubeconfig playbook
ANSIBLE_INVENTORY="$PWD/.ansible/hosts" \
ansible-playbook playbooks/get-kubeconfig.yaml \
  -e "ansible_vars_file=$PWD/ansible-vars.yaml known_hosts_file=$PWD/.ssh/known_hosts"

# Check cluster status
./ssh-node kubeapi
kubectl get nodes
```

### File Locations

- `.ansible/hosts` - Ansible inventory
- `ansible-vars.yaml` - Cluster variables
- `.ssh/config` - SSH configuration
- `.ssh/known_hosts` - SSH known hosts
- `terraform.tfstate` - Terraform state file

### Common IPs

- Gateway IP: `<gateway-ip>` (from ansible-vars.yaml)
- Control Plane Nodes: `10.0.1.2`, `10.0.1.3`, `10.0.1.4`
- Worker Nodes: `10.0.1.5`, `10.0.1.6`, `10.0.1.7`
- Kubernetes API: `localhost:6443` (via tunnel) or `<gateway-ip>:6443`

## Getting Help

If you're still experiencing issues:

1. Check the main [README.md](README.md) for configuration details
2. Review [ANSIBLE.md](ANSIBLE.md) for Ansible-specific guidance
3. Check [AGENTS.md](AGENTS.md) for additional troubleshooting steps
4. Review logs:
   - Hetzner Cloud Console for server status
   - `journalctl -u k3s` for k3s logs
   - `cloud-init status` for initialization status
