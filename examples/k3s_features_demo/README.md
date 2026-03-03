# k3s Features Demo

This example demonstrates the new file-based k3s configuration approach.

## Features Demonstrated

1. **Traefik Ingress Controller** - Built-in ingress controller enabled
2. **ServiceLB** - Simple load balancer enabled
3. **Local Storage** - Nodes' local storage provider enabled
4. **Custom kube-proxy Configuration** - Shows how to provide custom configuration for features

## Configuration Files Created

The module automatically creates the following configuration files:

- `/etc/rancher/k3s/config.yaml.d/00-default.yaml`
  - Default configuration (identical on all server nodes)
  - Network settings, cloud provider, TLS SANs, etc.

- `/etc/rancher/k3s/config.yaml.d/10-user.yaml`
  - User-configurable features (enable/disable k3s components)
  - Based on the `k3s_features` variable

- `/etc/rancher/k3s/config.yaml.d/20-nodepool.yaml`
  - Node-pool specific configuration
  - Labels, taints, kube-apiserver args

- `/etc/rancher/k3s/config.yaml.d/10-{feature}-user.yaml`
  - Feature-specific custom configuration (optional)
  - In this example: kube-proxy custom config

## Available Features

- **traefik**: Enable to use the built-in Traefik ingress controller
- **servicelb**: Enable to use the built-in service load balancer
- **local-storage**: Enable to use nodes' local storage provider
- **metrics-server**: Enable to install the built-in metrics server
- **kube-proxy**: Is enabled by default, custom configuration can be provided
- **helm-controller**: Enable to install the built-in helm controller

## Usage

1. Copy this example:
   ```bash
   cp -r examples/k3s_features_demo my-demo-cluster
   cd my-demo-cluster
   ```

2. Configure your Hetzner tokens:
   ```bash
   export TF_VAR_hcloud_token=your_token
   export TF_VAR_hcloud_token_read_only=your_readonly_token
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

5. Verify the configuration:
   ```bash
   kubectl get nodes
   kubectl get pods -A | grep traefik
   ```

## Verification

After deployment, you can verify the configuration files:

```bash
# SSH to a control plane node
ssh demo-admin@<node-ip>

# Check the configuration files
cat /etc/rancher/k3s/config.yaml.d/00-default.yaml
cat /etc/rancher/k3s/config.yaml.d/10-user.yaml
cat /etc/rancher/k3s/config.yaml.d/20-nodepool.yaml
cat /etc/rancher/k3s/config.yaml.d/10-kube-proxy-user.yaml
```

## Cost Estimation

This example uses the following resources:

- Gateway: cpx11 (~€14.90/month)
- Control Plane Nodes (3x cpx21): ~3 × €21.90 = €65.70/month
- Worker Nodes (3x cpx21): ~3 × €21.90 = €65.70/month
- **Total**: ~€146.30/month (excludes bandwidth and traffic)

## Notes

- Most k3s features are intentionally disabled to avoid conflicts with external solutions
- This example enables Traefik and ServiceLB, which may conflict with other ingress/load balancer solutions
- The custom kube-proxy configuration demonstrates advanced usage
- Changes to configuration files require a k3s restart to take effect
- This is a demo setup - adjust resources and features for production use
