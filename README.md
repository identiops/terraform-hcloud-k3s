![license](https://img.shields.io/github/license/identiops/terraform-hcloud-k3s)

[![stars](https://img.shields.io/github/stars/identiops/terraform-hcloud-k3s)](https://github.com/identiops/terraform-hcloud-k3s)

# Kubernetes Terraform installer for Hetzner Cloud

This Terraform module creates a Kubernetes Cluster on
[Hetzner Cloud](https://console.hetzner.cloud/) infrastructure running Ubuntu
22.04. The module aims to be simple to use while providing an out-of-the-box
secure and maintainable setup. Thanks to Ubuntu's LTS version we get up to 5
years of peace and quiet before having to upgrade the cluster's operating
system!

Terraform module published at:
<https://registry.terraform.io/modules/identiops/k3s/hcloud>

What changed in the latest version? See
[CHANGELOG.md](https://github.com/identiops/terraform-hcloud-k3s/tree/main/CHANGELOG.md).

![infrastructure](https://raw.githubusercontent.com/identiops/terraform-hcloud-k3s/main/infrastructure.png)

## Features

- [k3s](https://k3s.io/) based Kubernetes cluster.
- Node pools for managing cluster resources efficiently. Pools can be added,
  resized, and removed at any time.
- Automated Kubernetes update management via
  [System Upgrade Controller](https://github.com/rancher/system-upgrade-controller).
- Automated operating system updates with automatic system reboots via
  [kured](https://kured.dev).
- Creation of placement groups for to improve availability.
- Secured default configuration:
  - Deletion protection for all cloud resources.
  - SSH key required for remote access.
  - fail2ban limits SSH brute force attacks.
  - Cluster nodes have no public network interface.
  - Internal firewall active on all nodes for minimal exposure.
  - Support for network policies via [Cilium](https://www.cilium.io/).
  - [CSI hardening guide](https://docs.k3s.io/security/hardening-guide) applied:
    - Kernel parameters defined.
    - Audit log directory created.
    - Network policies, pod security policies, admission policies and the
      enabling of audit logs are up to the administrator of the cluster to
      configure.
- Integration of Hetzner Cloud Controller Manager for managing cloud resources
  from the within the cluster.
- Integration of Hetzner Cloud Storage Interface for managing volumes from the
  within the cluster.
- Ansible integration with automatically generated inventory.
- Convenience scripts for retrieving the Kubernetes configuration and accessing
  nodes via SSH and SCP.
- Calculation of monthly costs for every part of the deployment (see
  `terraform output`).
- Documentation of common administrative tasks and troubleshooting approaches.

### To be added

- OIDC support for user authentication. Some configuration is in place, but it
  hasn't been tested, yet.

<!-- generated with
!deno run --unstable --allow-read --allow-write https://deno.land/x/remark_format_cli@v0.1.0/remark-format.js %
-->

## Contents

1. [Getting Started](#getting-started)
   1. [Prerequisites](#prerequisites)
   2. [Recommended Tools](#recommended-tools)
   3. [Installation](#installation)
   4. [Usage](#usage)
2. [Maintenance](#maintenance)
   1. [Ansible: Execute Commands on Nodes](#ansible-execute-commands-on-nodes)
   2. [Add Ingress Controller and Load Balancer](#add-ingress-controller-and-load-balancer)
   3. [Add Nodes or Node Pools](#add-nodes-or-node-pools)
   4. [Remove Nodes or Node Pools](#remove-nodes-or-node-pools)
   5. [Stop Automated Node Reboots](#stop-automated-node-reboots)
   6. [Upgrade Operating System](#upgrade-operating-system)
      1. [Gateway Node](#gateway-node)
      2. [Node Pools](#node-pools)
   7. [Update Kubernetes](#update-kubernetes)
   8. [Update Cilium](#update-cilium)
   9. [Update Hetzner Cloud Controller Manager (CCM)](#update-hetzner-cloud-controller-manager-ccm)
   10. [Update Hetzner Cloud Storage Interface (CSI)](#update-hetzner-cloud-storage-interface-csi)
3. [Deletion](#deletion)
4. [Troubleshooting](#troubleshooting)
   1. [Gateway](#gateway)
      1. [Verify packet masquerading is set up properly](#verify-packet-masquerading-is-set-up-properly)
      2. [Verify firewall is set up properly](#verify-firewall-is-set-up-properly)
   2. [Cluster](#cluster)
      1. [Verify default route is configured properly](#verify-default-route-is-configured-properly)
      2. [Verify connectivity to the internet](#verify-connectivity-to-the-internet)
      3. [Verify name resolution](#verify-name-resolution)
      4. [Verify cluster status](#verify-cluster-status)
      5. [Verify Cilium Networking Status](#verify-cilium-networking-status)
      6. [Verify k3s Cluster Configuration](#verify-k3s-cluster-configuration)
      7. [Inspect cluster status and logs](#inspect-cluster-status-and-logs)
   3. [Nodes](#nodes)
      1. [Inspect local firewall settings](#inspect-local-firewall-settings)
      2. [Verify correctness of date/timezone and locale](#verify-correctness-of-datetimezone-and-locale)
      3. [Inspect cloud-init logs](#inspect-cloud-init-logs)
5. [Related Documentation](#related-documentation)
6. [Similar Projects](#similar-projects)
7. [Special Thanks](#special-thanks)

## Getting Started

### Prerequisites

- [Terraform](https://terraform.io) or [OpenTofu](https://opentofu.org/). Note
  that you'll need Terraform v1.0 or newer to run this project.
- `bash`
- `ssh`
- `kubectl`
- `jq`

### Recommended Tools

- [Ansible](https://www.ansible.com/)

### Installation

1. Create a Hetzner Cloud API token.
   - Register with [Hetzner Cloud](https://console.hetzner.cloud).
   - Create a new project.
   - Navigate to the security settings.
   - Select the "API tokens" tab and add a new token with **read & write**
     access.
   - Pass the token to terraform via an environment variable:

```bash
# Enter your Hetzner Cloud API Token (it will be hidden)
read -sp "Hetzner Cloud API Token: " TF_VAR_hcloud_token
export TF_VAR_hcloud_token
```

2. Create a second Hetzner Cloud API token with just **read** access.
   - Pass the token to terraform via an environment variable:

```bash
# Enter your Hetzner Cloud API Token (it will be hidden)
read -sp "Hetzner Cloud API read only Token: " TF_VAR_hcloud_token_read_only
export TF_VAR_hcloud_token_read_only
```

3. Download
   [`examples/2ControlPlane_3Worker_Nodes/main.tf`](https://github.com/identiops/terraform-hcloud-k3s/blob/main/examples/2ControlPlane_3Worker_Nodes/main.tf):
   `curl -LO https://github.com/identiops/terraform-hcloud-k3s/raw/main/examples/2ControlPlane_3Worker_Nodes/main.tf`
4. Adjust the cluster configuration in `main.tf`, e.g.
   - `cluster_name`
   - `location`
   - `k3s_version`
   - `ssh_keys` (to create a new ssh key run: `ssh-keygen -t ed25519`)
   - `node_pools`
5. Initialize the configuration: `terraform init`
6. Apply the configuration: `terraform apply`
7. Grab a coffee and enjoy the servers popping up in Hetzner's cloud console.
   Wait for about 5 minutes.
8. Test SSH access to the cluster: `./ssh-node cluster`
   - ATTENTION: don't hammer the cluster with failing SSH requests, or you'll be
     banned by your cluster automatically! If the request fails, because the
     cluster node isn't ready yet, wait another minute.
9. Once SSH connection is established, double check that everything is working
   as expected:
   - Did the node initialization finish successfully? `cloud-init status`
   - Is the cluster up and running? `kubectl cluster-info`
10. If the tests were successful, retrieve the Kubernetes configuration locally:
    `./setkubeconfig`

Enjoy your new cluster! 🚀

### Usage

Start using your favorite Kubernetes tools to interact with the cluster. One of
the first steps usually involves
[deploying an ingress controller](#add-ingress-controller-and-load-balancer)
since this configuration doesn't ship with one.

In addition, a few convenience scripts were created to help with maintenance:

- `setkubeconfig`: retrieves and stores the Kubernetes configuration locally.
- `unsetkubeconfig`: removes the cluster from the local Kubernetes
  configuration.
- `ls-nodes`: lists the nodes that are part of the cluster for access via
  `ssh-node` and `scp-node`.
- `ssh-node`: SSH wrapper for connecting to cluster nodes.
- `scp-node`: SCP wrapper for connecting to cluster nodes.
- `.ssh/config`: SSH configuration for the cluster nodes.

## Maintenance

### Ansible: Execute Commands on Nodes

This module automatically generates an
[Ansible inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#connecting-to-hosts-behavioral-inventory-parameters)
in file `.ansible/hosts`. It can be leveraged to interact with the nodes and
node pools of the cluster.

Example: Execute a command on all control plane nodes

```bash
ANSIBLE_INVENTORY=$PWD/.ansible/hosts ansible all_control_plane_nodes -a "kubectl cluster-info"
```

### Add Ingress Controller and Load Balancer

Since this module doesn't ship an ingress controller, one of the first
configurations applied to the cluster is usually an ingress controller. Good
starting points for an ingress controller are:

- [traefik](https://artifacthub.io/packages/helm/traefik/traefik)
- [ingress-nginx](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx)

The ingress controller, like the rest of the cluster, is not directly exposed to
the Internet. Therefore, it is necessary to add a load balancer that is directly
exposed to the Internet and has access to the local network of the cluster. The
load balancer is added to the cluster simply by adding annotations to the
ingress controller's service. Hetzner's Cloud Controller Manager will use the
annotations to deploy and configure the load balancer.

The following annotations should be used:

- Resource name: `load-balancer.hetzner.cloud/name: "ingress-lb"`
- Protocol, just `tcp` - the ingress controller will take care of the HTTP
  connection: `load-balancer.hetzner.cloud/protocol: "tcp"`
- Location, same as the one used for the cluster:
  `load-balancer.hetzner.cloud/location: "nbg1"`
- Connection to the servers, must be set to `true`:
  `load-balancer.hetzner.cloud/use-private-ip: "true"`
- Size, see [options](https://docs.hetzner.com/cloud/load-balancers/overview):
  `load-balancer.hetzner.cloud/type: "lb11"`
- See
  [list of all supported Load Balancer Annotations](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/main/internal/annotation/load_balancer.go).

Furthermore, for domain names to work, it is required to point DNS records to
the IP address of load balancer.
[external-dns](https://artifacthub.io/packages/helm/external-dns/external-dns)
is a helpful tool that can automate this task from within the cluster. For this
to work well with Ingress resources, the ingress controller needs to
[expose the published service information](https://kubernetes-sigs.github.io/external-dns/v0.14.0/faq/#which-service-and-ingress-controllers-are-supported)
on the Ingress resources.

### Add Nodes or Node Pools

The number of nodes in a node pool can be increased at any point. Just increase
the count and apply the new configuration via `terraform apply`. After a few
minutes the additional nodes will appear in the cluster.

In the same way, node pools can be added to the configuration without any
precaution.

### Remove Nodes or Node Pools

Removing nodes requires the following steps:

1. Identify the nodes and node pools that shall be removed. If the number of
   nodes in a node pool needs to be decreased, the nodes will be removed from
   the highest to the lowest number. Example: when the number of nodes in pool
   `system` is decreased from `3` to `2`, node `cluster-system-02` will be
   removed and nodes `cluster-system-01` and `cluster-system-00` will remain.
2. Drain all nodes that will be removed of pods:
   `kubectl drain cluster-system-02`
3. Wait until all pods have been migrated to other nodes before continuing.
   - If you drained the wrong node, you can reactivate the node with:
     `kubectl uncordon cluster-system-02`
4. Update the terrafrom configuration and apply it: `terraform apply`
   - Review the plan to verify that the drained nodes will be deleted.
5. Delete nodes from cluster: `kubectl delete node cluster-system-02`

### Stop Automated Node Reboots

Nodes are rebooting automatically when they receive updates that require a
reboot. The kured service triggers reboots of nodes one by one. Reboots can be
disabled system-wide by annotating the Daemonset, see
https://kured.dev/docs/operation/.

### Upgrade Operating System

WARNING: untested!

An operating system update is not recommended, e.g. from Ubuntu 22.04 to 24.04.
Instead, the corresponding nodes should be replaced!

#### Gateway Node

1. Delete the node in the [Hetzner Console](https://console.hetzner.cloud/)
2. Reapply the configuration: `terraform apply`

The gateway will reappear again within a few minutes. This will disrupt the
Internet access of the cluster's nodes for tasks like fetching package updates.
However, it will not affect the services that are provided via load balancers!

#### Node Pools

Nodes should not be updated manually via `agt-get`, but be replaced. For control
plane nodes, it is recommended to create a back-up of the etcd data store on an
external s3 storage, see [k3s Cluster Datastore](https://docs.k3s.io/datastore).

1. For control plane pools only: Create a new etcd snapshot, see
   [k3s etcd-snapshot](https://docs.k3s.io/cli/etcd-snapshot).
2. Set the new `image` in the configuration. Then, perform the following steps
   on consecutively on all existing node pools until they have all been
   replaced.

Start the replacement with the node pool with the `cluster_can_init` setting:

3. Ensure that there's another control plane node pool. If there's no other
   control plane node pool, create a temporary one that is deleted after the
   successful replacement of the node pool with the `cluster_can_init` setting.
4. When the second control plane node pool is up and running, the node pool with
   the `cluster_can_init` setting must be deleted and replaced in one
   application of the configuration.
   - Ensure that the `cluster_init_action.init` and `cluster_init_action.reset`
     settings are disabled.
   - Drain the old nodes: `kubectl drain node-xyz`
   - Once all pods have been migrated, delete the old nodes:
     `kubectl delete node node-xyz`
   - Then rename the node pool to achieve deletion and replacement in one
     configuration change.
   - Apply the configuration: `terraform apply`
   - Once the new control plane node pool with the `cluster_can_init` setting is
     again up and running, the temporary control plane node pool can be deleted.

Perform these steps for all remaining node pools:

5. Add a new node pool.
6. Once the new node pool is up and running, drain the old nodes:
   `kubectl drain node-xyz`
7. Once all pods have been migrated, delete the old nodes:
   `kubectl delete node node-xyz`
8. Remove the node pool from the terraform configuration.
9. Reapply the configuration: `terraform apply`

### Update Kubernetes

1. Determine the next Kubernetes version, see
   [k3s channels](https://update.k3s.io/v1-release/channels),
   [k3s images tags](https://hub.docker.com/r/rancher/k3s/tags), and
   [k3s upgrade image tags](https://hub.docker.com/r/rancher/k3s-upgrade/tags).
2. Write the upgrade plan, see
   [instructions](https://docs.k3s.io/upgrades/automated) and
   [examples](https://github.com/rancher/system-upgrade-controller#example-plans).
3. Apply an upgrade plan.
4. Update the `image` variable in the configuration for future nodes to be
   deployed with the correct image.

### Update Cilium

See <https://docs.cilium.io/en/stable/operations/upgrade/>

### Update Hetzner Cloud Controller Manager (CCM)

See
<https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/main/CHANGELOG.md>

### Update Hetzner Cloud Storage Interface (CSI)

See <https://github.com/hetznercloud/csi-driver/blob/main/CHANGELOG.md>

## Deletion

After applying the Terraform plan you'll see several output variables like the
load balancer's, control plane's, and node pools' IP addresses.

```bash
terraform destroy -force
```

Be sure to clean up any CSI created Block Storage Volumes, and CCM created
NodeBalancers that you no longer require.

## Troubleshooting

### Gateway

Ensure gateway is set up correctly: `./ssh-node gateway`

#### Verify packet masquerading is set up properly

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

#### Verify Cilium Networking Status

This command only works out of the box on the first node of the control plane
node pool with the `cluster_can_init` setting.

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
cilium status

# Expected output:
#     /¯¯\
#  /¯¯\__/¯¯\    Cilium:             OK
#  \__/¯¯\__/    Operator:           OK
#  /¯¯\__/¯¯\    Envoy DaemonSet:    disabled (using embedded mode)
#  \__/¯¯\__/    Hubble Relay:       disabled
#     \__/       ClusterMesh:        disabled
# 
# Deployment             cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
# DaemonSet              cilium             Desired: 3, Ready: 3/3, Available: 3/3
# Containers:            cilium             Running: 3
#                        cilium-operator    Running: 1
# Cluster Pods:          9/9 managed by Cilium
# Helm chart version:    1.14.5
# Image versions         cilium             quay.io/cilium/cilium:v1.14.5@sha256:d3b287029755b6a47dee01420e2ea469469f1b174a2089c10af7e5e9289ef05b: 3
#                        cilium-operator    quay.io/cilium/operator-generic:v1.14.5@sha256:303f9076bdc73b3fc32aaedee64a14f6f44c8bb08ee9e3956d443021103ebe7a: 1
```

#### Verify k3s Cluster Configuration

This command only works out of the box on the first node of the control plane
node pool with the `cluster_can_init` setting.

```bash
k3s check-config

# Expected output:
# ...
# STATUS: pass
```

#### Inspect cluster status and logs

```bash
systemctl status k3s.service

journalctl -u k3s.service
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
