# Agent Instructions

## Troubleshooting

### SSH Connection Issues

When encountering SSH connection issues with the cluster:

1. **Read the troubleshooting section** in [README.md](README.md#troubleshooting) (lines 841-1021)
2. Key checks:
   - Wait ~5 minutes after deployment for cluster initialization
   - Verify gateway connectivity: `./ssh-node gateway`
   - Check cloud-init status on nodes: `cloud-init status`
   - Verify gateway masquerading: `iptables -L -t nat`
   - Verify default route on nodes: `ip r s`
   - Check firewall: `ufw status`

### Common Issues

| Issue | Solution |
|-------|----------|
| SSH to cluster hangs | Wait for cluster initialization (~5 min) |
| Port 6443 in use | Kill existing SSH tunnel: `pkill -f "ssh.*6443"` |
| Known hosts conflict | `ssh-keygen -f .ssh/known_hosts -R <gateway-ip>` |
| Cannot connect to cluster nodes | Ensure SSH agent forwarding is enabled: `ssh -A root@<gateway-ip>` |

### Ansible Troubleshooting

When encountering Ansible connection issues with the cluster:

1. **Check SSH agent forwarding is enabled**:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

2. **Verify generated files exist**:
   ```bash
   ls -la .ansible/hosts ansible-vars.yaml .ssh/config
   ```

3. **Test SSH connection to control plane node**:
   ```bash
   ssh -A root@<gateway-ip> 'ssh -o StrictHostKeyChecking=no <node-ip> hostname'
   ```

4. **Verify k3s is installed on nodes**:
   ```bash
   ANSIBLE_INVENTORY="$PWD/.ansible/hosts" ansible all_control_plane_nodes -a "which k3s"
   ```

5. **Use k3s kubectl instead of kubectl**:
   ```bash
   ANSIBLE_INVENTORY="$PWD/.ansible/hosts" ansible all_control_plane_nodes -a "k3s kubectl get nodes"
   ```
