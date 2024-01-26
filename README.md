<div style="display: flex; gap: 10px;">

![license](https://img.shields.io/github/license/identiops/terraform-hcloud-k3s)

![stars](https://img.shields.io/github/stars/identiops/terraform-hcloud-k3s)

</div>

# Kubernetes Terraform installer for Hetzner Cloud

This Terraform module creates a Kubernetes Cluster on
[Hetzner Cloud](https://console.hetzner.cloud/) infrastructure running Ubuntu
22.04. The module aims to be simple to use while providing an out-of-the-box
secure and maintainable setup. Thanks to Ubuntu's LTS version we get up to 5
years of peace and quiet before having to upgrade the cluster's operating
system!

Terraform module published at:
[https://registry.terraform.io/modules/identiops/k3s/hcloud]()

What changed in the latest version? See
[CHANGELOG.md](https://github.com/identiops/terraform-hcloud-k3s/tree/main/CHANGELOG.md).

![infrastructure](https://raw.githubusercontent.com/identiops/terraform-hcloud-k3s/main/infrastructure.png)

## Features

- [k3s](https://k3s.io/) based kubernetes cluster.
- Kubernetes update management via
  [System Upgrade Controller](https://github.com/rancher/system-upgrade-controller).
- Secured default configuration:
  - Cluster nodes have no public network interface.
  - SSH key required for remote access.
  - `fail2ban` limits SSH brute force attacks.
  - Internal firewall on all nodes with minimal exposure.
  - Cluster is not exposed to incoming traffic from the Internet after the
    initial setup. The cluster administrator starts exposing the cluster by
    deploying a load balancer, e.g. by annotating an installed ingress
    controller.
  - [CSI hardening guide](https://docs.k3s.io/security/hardening-guide) applied
    partially
    - Kernel parameters defined.
    - Audit log directory created.
    - Network policies, pod security policies, admission policies and the
      enabling of audit logs are up to the administrator of the cluster to
      configure.
- Calculation of monthly costs for every part of the deployment (see
  `terraform output`).
- Node pools for managing cluster resources efficiently. Minimum cluster size is
  _one_ node. Pools can be added, resized, and removed at any time.
- Automatic use of placement groups for node pools to improve availability.
- Automatic operating system updates with optional automatic reboots via
  [kured](https://kured.dev).
- Deletion protection for all cloud resources.
- Support for network policies via [Cilium](https://www.cilium.io/).
- Hetzner Cloud Controller Manager for managing cloud resources from the within
  the cluster.
- Hetzner Cloud Storage Interface for managing volumes from the within the
  cluster.
- Convenience scripts for downloading the kubernetes configuration and accessing
  nodes via SSH/SCP.
- Documentation of common administrative tasks and debugging tools.

### To be added

- OIDC support for user authentication. Some configuration is in place but it
  hasn't been tested, yet.

## Install

### Prerequisites

- [Terraform](https://terraform.io) or [OpenTofu](https://opentofu.org/)
- Bash
- SSH with an SSH Key and Agent
- `kubectl`
- `jq` installed is recommended

Note that you'll need Terraform v1.0 or newer to run this project.

### Hetzner Cloud API Token

Before running the project you'll have to create an access token for Terraform
to connect to the Hetzner Cloud API. Connect to the
[Hetzner cloud](https://console.hetzner.cloud), navigate to your project, select
security settings - API tokens and create a new token.

```bash
read -sp "Hetzner Cloud API Token: " TF_VAR_hcloud_token # Enter your Hetzner Cloud API Token (it will be hidden)
export TF_VAR_hcloud_token
```

## Usage

### Initialization

Make a copy of the
[`examples/`](https://github.com/identiops/terraform-hcloud-k3s/tree/main/examples)
directory on your local file system.

- Run `terraform init`
- Modify the `cluster` section in
  [`main.tf`](https://github.com/identiops/terraform-hcloud-k3s/blob/main/examples/main.tf)
  to your liking, e.g. `cluster_name`, `k3s_version`, `ssh_keys`, and
  `node_pools`.

That's all it takes to get started!

Pin to a specific module version using `version = "..."` to avoid upgrading to a
version with breaking changes. Upgrades to this module could potentially replace
all control plane and worker nodes resulting in data loss. The `terraform plan`
will report this, but it may not be obvious.

### Creation

Create an Hetzner Cloud Kubernetes cluster with one control plane and a worker
node:

```bash
terraform apply
```

This will do the following:

- Provisions Hetzner Cloud Instances with Ubuntu (the instance type/size of the
  control plane and worker node pools may be different).
- Installs K3S components and supporting binaries.
- Joins the nodes in the cluster.
  - Installs Hetzner Cloud add-ons:
    - [CSI](https://github.com/hetznercloud/csi-driver) (Container Storage
      Interface driver for Hetzner Cloud Volumes)
    - [CCM](https://github.com/hetznercloud/hcloud-cloud-controller-manager)
      (Kubernetes cloud-controller-manager for Hetzner Cloud)
- Creates two bash scripts `setkubeconfig` and `unsetkubeconfig` to
  setup/destroy new context in the kubectl admin config file.
- Creates `ssh-node`, `scp-node`, and `ls-nodes` bash script and an ssh
  configuration to quickly connect to all servers.

### Maintenance

#### Add Load Balancer

Add annotations to the service of type load balancer, e.g. the ingress
controller. A new load balancer will be added via the Hetzner Cloud Controller
Manager and configured to route traffic to the service.

See
[List of supported Load Balancer Annotations](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/main/internal/annotation/load_balancer.go).

Useful annotations:

- `load-balancer.hetzner.cloud/protocol: "tcp"`
- `load-balancer.hetzner.cloud/location: "fsn1"`
- `load-balancer.hetzner.cloud/use-private-ip: "true"` - route traffic to the
  internal interface of the servers.
- `load-balancer.hetzner.cloud/type: "lb11"` - the type of load balancer, see
  https://docs.hetzner.com/cloud/load-balancers/overview

#### Add Nodes or Node Pools

The number of nodes in a node pool can be increased at any point. Just increase
the count and apply the new configuration via `terraform apply`. After a few
minutes the additional nodes will appear in the cluster.

In the same way, node pools cann be added to the configuration without any
precaution.

#### Remove Nodes or Node Pools

Removing a nodes requires the following steps:

1. Identify the nodes and node pools that shall be removed. If the number of
   nodes in a node pool needs to be decreased, the nodes will be removed from
   the highest to the lowest number. Example: when the number of nodes in pool
   `system` is decreased from `3` to `2`, node `cluster-system-02` will be
   removed and nodes `cluster-system-01` and `cluster-system-00` will remain.
2. Drain all nodes that will be removed of pods:
   `kubectl drain cluster-system-02`
3. Wait until all pods have been migrated to other nodes before continuing.
   - If the wrong node was drained, reactivate the node:
     `kubectl uncordon cluster-system-02`
4. Update the terrafrom configuration and apply it: `terraform apply`
   - Review the plan to verify that the drained nodes will be deleted.
5. Delete nodes from cluster: `kubectl delete node cluster-system-02`

#### Stop Automated Node Reboots

Nodes are rebooting automatically when they receive updates that require a
reboot. The kured service triggers the reboots of nodes one by one. Reboots can
be disabled system wide by annotating the Daemonset, see
https://kured.dev/docs/operation/.

#### Upgrade Operating System

WARNING: untested!

An operating system update is not recommended, e.g. from Ubuntu 22.04 to 24.04.
Instead, the corresponding nodes should be replaced!

##### Gateway

1. Delete the node in the [Hetzner Console](https://console.hetzner.cloud/)
2. Reapply the configuration: `terraform apply`

The gateway will reappear again within a few minutes. This will disrupt the
internet access of the cluster's nodes for tasks like fetching package updates.
However, it will not affect the services that are provided via load balancers!

##### Node Pool

Nodes should not be updated manually via `agt-get`, but be replaced. For control
plane nodes, it is recommended to backup the etcd data store to an external s3
storage, see [k3s Cluster Datastore](https://docs.k3s.io/datastore).

Perform theses steps ONLY for the node pool with the `cluster_can_init` setting:

1. For control plane pools only: Create a new etcd snapshot, see
   [k3s etcd-snapshot](https://docs.k3s.io/cli/etcd-snapshot).
2. For control plane pools only: Ensure that the `cluster_init_action.init` and
   `cluster_init_action.reset` settings are disabled.
3. Add a temporary node pool with the `is_control_plane` setting.
4. Reapply the configuration: `terraform apply`
5. Once the new node pool is up and running, drain the old nodes:
   `kubectl drain node-xyz`
6. Once all pods have been migrateded, delete the old nodes:
   `kubectl delete node node-xyz`
7. Change the `image` of the node pool with the `cluster_can_init` setting.
8. Reapply the configuration - the nodes are recreated with the new image:
   `terraform apply`
9. Once the node pool is up and running, drain the nodes of the temporary pool:
   `kubectl drain node-xyz`
10. Once all pods have been migrateded, delete the nodes of the temporary pool:
    `kubectl delete node node-xyz`
11. Remove the temporary node pool from the terraform configuration.
12. Reapply the configuration: `terraform apply`

Perform theses steps for all node pools, except the one with the
`cluster_can_init` setting:

1. For control plane pools only: Create a new etcd snapshot, see
   [k3s etcd-snapshot](https://docs.k3s.io/cli/etcd-snapshot).
2. For control plane pools only: Ensure that the `cluster_init_action.init` and
   `cluster_init_action.reset` settings are disabled.
3. Add a new node pool that uses the new image.
   - For the control plane pool with the `cluster_can_init` setting: Ensure that
     the `cluster_init_action.init` and
4. Once the new node pool is up and running, drain the old nodes:
   `kubectl drain node-xyz`
5. Once all pods have been migrateded, delete the old nodes:
   `kubectl delete node node-xyz`
6. Remove the node pool from the terraform configuration.
7. Reapply the configuration: `terraform apply`

#### Update Kubernetes

1. Determine the next kubernetes version, see
   [k3s images tags](https://hub.docker.com/r/rancher/k3s/tags) and
   [k3s upgrade image tags](https://hub.docker.com/r/rancher/k3s-upgrade/tags).
2. Write the ugrade plan, see
   [instructions](https://docs.k3s.io/upgrades/automated) and
   [examples](https://github.com/rancher/system-upgrade-controller#example-plans).
3. Apply an upgrade plan.
4. Update the `image` variable in the configuration for future nodes to be
   deployed with the correct image.

#### Update Cilium

See https://docs.cilium.io/en/stable/operations/upgrade/

#### Update Hetzner Cloud Controller Manager (CCM)

See
https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/main/CHANGELOG.md

#### Update Hetzner Cloud Storage Interface (CSI)

See https://github.com/hetznercloud/csi-driver/blob/main/CHANGELOG.md

### Deletion

After applying the Terraform plan you'll see several output variables like the
load balancer's, control plane's, and node pools' IP addresses.

```bash
terraform destroy -force
```

Be sure to clean-up any CSI created Block Storage Volumes, and CCM created
NodeBalancers that you no longer require.

## Debugging

### Gateway

Ensure gateway is set up correctly: `./ssh-node gateway`

#### Verify packet masquarading is set up properly

```bash
iptables -L -t nat

# Expected output:
# Chain PREROUTING (policy ACCEPT)
# target     prot opt source               destination
#
# Chain INPUT (policy ACCEPT)
# target     prot opt source               destination
#
# Chain OUTPUT (policy ACCEPT)
# target     prot opt source               destination
#
# Chain POSTROUTING (policy ACCEPT)
# target     prot opt source               destination
# MASQUERADE  all  --  10.0.1.0/24          anywhere
```

#### Verify firewall is set up properly

```bash
ufw status

# Expected output:
# Status: active
#
# To                         Action      From
# --                         ------      ----
# 22,6443/tcp                ALLOW       Anywhere
# 22,6443/tcp (v6)           ALLOW       Anywhere (v6)
#
# Anywhere on eth0           ALLOW FWD   Anywhere on ens10
# Anywhere (v6) on eth0      ALLOW FWD   Anywhere (v6) on ens10
```

### Cluster

Ensure cluster is set up correctly: `./ssh-node cluster`

#### Verify default route is configured properly

```bash
ip r s

# Expected output:
# default via 10.0.0.1 dev ens10 proto static onlink <-- this is the important line
# 10.0.0.0/8 via 10.0.0.1 dev ens10 proto dhcp src 10.0.1.2 metric 1024
# 10.0.0.1 dev ens10 proto dhcp scope link src 10.0.1.2 metric 1024
# 169.254.169.254 via 10.0.0.1 dev ens10 proto dhcp src 10.0.1.2 metric 1024
```

#### Verify connectivity to the internet

```bash
ping 1.1.1.1

# Expected output:
# PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
# 64 bytes from 1.1.1.1: icmp_seq=1 ttl=53 time=4.60 ms
# 64 bytes from 1.1.1.1: icmp_seq=2 ttl=53 time=6.82 ms
# ...
```

#### Verify name resolution

```bash
host k3s.io

# Expected output:
# k3s.io has address 185.199.108.153
# k3s.io has address 185.199.110.153
# k3s.io has address 185.199.111.153
# k3s.io has address 185.199.109.153
# ...
```

#### Verify cluster status

```bash
k3s kubectl get nodes

# Expected output:
# k3s.io has address 185.199.108.153
# k3s.io has address 185.199.110.153
# k3s.io has address 185.199.111.153
# k3s.io has address 185.199.109.153
# ...
```

#### Inspect cluster status and logs

```bash
systemctl status k3s.service

journalctl -u k3s.service
```

### Nodes

#### Inspect local firewall settings

```bash
ufw status
```

#### Verify correctness of date/timezone and locale

```bash
date

echo $LANG
```

#### Inspect cloud-init logs

```bash
# Retrieve status
cloud-init status

# Verify configuration
cloud-init schema --system

# Collect logs for inspection
cloud-init collect-logs
tar xvzf cloud-init.tar.gz
# Inspect cloud-init.log for error messages

# Quickly find runcmd
find /var/lib/cloud/instances -name runcmd
sh -ex PATH_TO_RUNCMD
```

## Related Documentation

- [Cilium](https://docs.cilium.io/)
- [Cloud-init](https://cloudinit.readthedocs.io/)
- [Hetzner API](https://docs.hetzner.cloud/)
- [Hetzner Cloud Platform](https://docs.hetzner.com/cloud)
- [Terraform Module Registry](https://registry.terraform.io/)
- [Terraform](https://www.terraform.io/docs/)

## Similar Projects

- [hcloud-k3s](https://github.com/cicdteam/terraform-hcloud-k3s) Original
  project that this project has been forked from.
- [hetzner-cloud-k3s](https://github.com/vitobotta/hetzner-cloud-k3s) A fully
  functional, super cheap Kubernetes cluster in Hetzner Cloud in 1m30s or less
  - Not terraform-based.
  - Scripts that make it easy to manage a cluster.
- [hetzner-k3s](https://github.com/vitobotta/hetzner-k3s/) A CLI tool to create
  and manage Kubernetes clusters in Hetzner Cloud using the lightweight
  distribution k3s by Rancher. Successor of
  [hetzner-cloud-k3s](https://github.com/vitobotta/hetzner-cloud-k3s).
  - Not terraform-based.
- [k-andy](https://github.com/StarpTech/k-andy) Zero friction Kubernetes stack
  on Hetzner Cloud.
  - Terraform-based stack.
  - Distributed across multiple Hetzner sites and data centers.
  - Support for multiple control-plane servers.
- [terraform-hcloud-kube-hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner).
  Optimized and Maintenance-free Kubernetes on Hetzner Cloud in one command!

## Special Thanks

- The initiators of and contributors to this project for getting the k3s cluster
  running via terraform.
- And to God for providing and enabling me to do my share of this work. Solo Deo
  Gloria.
