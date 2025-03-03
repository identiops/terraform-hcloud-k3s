# Changelog

All notable changes to this project will be documented in this file.

## [4.2.1] - 2025-03-03

### Documentation

- Add link to OpenTofu registry and update ToC

## [4.2.0] - 2025-03-03

### Miscellaneous Tasks

- Open cilium hubble port 4244 on all nodes

## [4.1.3] - 2025-02-28

### Documentation

- Correct typos

### Miscellaneous Tasks

- Add gateway configuration
- Update to version 1.17.1

## [4.1.2] - 2025-02-12

### Bug Fixes

- Properly replace version in examples

### Documentation

- Describe how to use the kubeapi jump host configuration
- Move kubeapi docs do maintenance section
- Add an upgrade plan example

### Miscellaneous Tasks

- Update system-upgrade-controller to version 105.0.1
- Update system-upgrade-controller configuration
- Add ssh port-forwarding configuration

## [4.1.1] - 2025-02-11

### Features

- Add kubeapi jump account on gateway

## [4.1.0] - 2025-02-11

### Documentation

- Add apple silicon warning #19

### Features

- Support different network interface names depending on OS image

### Miscellaneous Tasks

- Silent _bump_files task

## [4.0.0] - 2025-02-10

### Bug Fixes

- Link to simple example in README
- Drop template dependency
- Change default node type to an existing type and validate node type in pools #11

### Documentation

- Fix topy
- Emphasize that the kubectl command is executed locally #13

### Miscellaneous Tasks

- Lift required version to 0.12.0
- Update dependencies
- Update bump version task
- Cleanup links
- Increase time to live for upgrade jobs
- Update dependencies
- Update terraform versions
- [**breaking**] Update ubuntu version to 24.04 and update dependencies #12

## [3.0.6] - 2024-03-18

### Documentation

- Add reference to kube-hetzner

### Features

- Make ICMP and kubernetes configurable in firewall

## [3.0.5] - 2024-02-19

### Documentation

- Correct links in toc

## [3.0.4] - 2024-02-19

### Features

- Perform dist-upgrade after initializing the cluster

## [3.0.3] - 2024-02-19

### Documentation

- Add helm and cilium as recommended tools
- Add detailed component update instructions

### Features

- Move component versions into module to simplify examples

## [3.0.2] - 2024-02-17

### Documentation

- Add k9s screenshot

## [3.0.1] - 2024-02-17

### Documentation

- Add an additional installation step

## [3.0.0] - 2024-02-17

### Bug Fixes

- Hide virtual `*` host

### Documentation

- Add more figures
- Correct reference to pictures

### Features

- Add local haproxy to all nodes to get high availibility

### Miscellaneous Tasks

- Make nu shell version configurable

## [2.6.0] - 2024-02-16

### Features

- Install ccm earlier and set additional tolerations
- Set k8sServiceHost to load balancer

### Miscellaneous Tasks

- Add infrastructure image source
- Migrate to system-upgrade-controller helm chart

## [2.5.3] - 2024-02-08

### Features

- Display net and gross with a precision of 2
- Make count width in node names configurable

## [2.5.2] - 2024-02-08

### Bug Fixes

- Sequentially process examples to mitigate locking issues

## [2.5.1] - 2024-02-08

### Documentation

- Add link to the example
- Name load balancing challenges when zone outages occur

### Features

- Use read only token to fetch prices
- Add multi-region example and improve default example

## [2.5.0] - 2024-02-07

### Documentation

- Correct typos
- Quote ansible variable contents

### Features

- Add support for multi-region deployments
- Support image configuration per node pool
- Make network zone configurable

### Miscellaneous Tasks

- Ignore ansible inventory
- Update version constraints

## [2.4.0] - 2024-02-02

### Bug Fixes

- Open all relevant kubernetes ports in the firewall
- Make kubectl exec and logs commands work

### Documentation

- Add ansible integration as feature
- Add examples to verify cilium and cluster configuration
- Describe how to add an ingress controller
- Add table of contents
- Add references to updating additional components

### Features

- Add links to charts

## [2.3.7] - 2024-02-01

### Features

- Auto-generate ansible inventory and describe usage

### Miscellaneous Tasks

- Add warning to auto-generated files

## [2.3.6] - 2024-01-30

### Documentation

- Add anchor to the getting started guide

## [2.3.5] - 2024-01-30

### Documentation

- Add instructions for using the example

## [2.3.4] - 2024-01-30

### Documentation

- Rename Debugging section to Troubleshooting
- Place examples in subfolder so they're found by the registry

## [2.3.3] - 2024-01-29

### Bug Fixes

- Pass only the read only token to the gateway script

## [2.3.2] - 2024-01-28

### Documentation

- Correct spelling

## [2.3.1] - 2024-01-28

### Bug Fixes

- Correct null error when retrieving gateway labels

## [2.3.0] - 2024-01-28

### Features

- Require a second read only access token for the gateway

## [2.2.0] - 2024-01-28

### Bug Fixes

- Restore the life cycle ignore settings for image and location
- Remove KUBECONFIG setting from scripts

### Documentation

- Clarify OS upgrade instructions
- Clarify installation instructions and rework feature list

### Features

- Make resources immune to changes to cluster_name
- Add image and location information to output

### Miscellaneous Tasks

- Improve SSH example configuration

## [2.1.1] - 2024-01-27

### Bug Fixes

- Add missing opentofu dependency

### Features

- Add s3 backend and etcd snapshot configuration

### Miscellaneous Tasks

- Print changes before confirming the release

## [2.1.0] - 2024-01-27

### Documentation

- Remove warning about hard coded gateway
- Simplify instructions for OS upgrades of the main node pool

### Features

- Replace sleep wait with cluster readiness check script

### Miscellaneous Tasks

- Create a github release for every new version
- Update copyright and add license identifiers to files

## [2.0.5] - 2024-01-26

### Documentation

- Remove last bit of s3 configuration

## [2.0.4] - 2024-01-26

### Miscellaneous Tasks

- Remove s3 sample configuation

## [2.0.3] - 2024-01-26

### Documentation

- Update infrastructure picture

## [2.0.2] - 2024-01-26

### Documentation

- Add link to github stars counter

## [2.0.1] - 2024-01-26

### Documentation

- Cleanup links

## [2.0.0] - 2024-01-26

### Documentation

- Correct typos and add hcloud-k3s reference

### Features

- Install metrics server via helm
- [**breaking**] Integrate control_plane_main into node_pools

### Miscellaneous Tasks

- Update husky
- Replace husky with a plain githooks folder
- Add validation for node_pools
- Replace hard-coded default gateway with a dynamic calculation
- Reorder firewall rules in gateway
- Manage all scripts in scripts.tf
- Use terraform registry module as the default source

## [1.0.0] - 2024-01-24

### Bug Fixes

- Add missing k3s --cloud-init switch

### Documentation

- Shorten link to terraform module
- Make runcmd debugging use sh -e
- Reorder documentation
- Document load balancer annotations
- Add a to be added section
- Add changelog reference

### Features

- Use haproxy on gateway to proxy port 6443
- Show ports and protocols in architecture picture
- Add node_count to pools and total costs output and optimize label output

### Miscellaneous Tasks

- Remove mandatory newline
- Change schedule to start at 1am
- Change no workload taint back to CriticalAddonsOnly
- Update description and lower suggested node size

## [0.2.0] - 2024-01-23

### Bug Fixes

- Syntax error in installation scirpt

### Documentation

- Improve k8s upgrade

## [0.1.5] - 2024-01-23

### Documentation

- Update output descriptions
- Add badges and link to terraform registry
- List more features
- Remove duplicated section Addons included

### Features

- Add variable for passing k3s options to main server
- Ignore changes to server ssh_keys and location
- Add and document restore and os upgrades
- Apply and document security hardening
- Add system upgrade controller

### Miscellaneous Tasks

- Allow inbound ICMP
- Prefix firewall with cluster name
- Remove local cloud init file

### Refactor

- Group all setup commands

## [0.1.4] - 2024-01-23

### Documentation

- Make references absolute to work on registry.terraform.io

### Miscellaneous Tasks

- Make version bump commit unconventional to not appear in the changelog

## [0.1.3] - 2024-01-23

### Bug Fixes

- Correct apiVersion of kustomization
- Reactivate flannel
- Reenable calico and correct network configuration
- Disable batch mode, it fails for proxied connections
- Correct workload scheduling variable meaning
- Disable IPv6 to make calico work
- Disable bgp
- Remove k8s firewall rules from gateway
- Add output of total monthly costs
- Replace calico with cilium
- Increase inotify limits to make log streaming work
- Remove dependency on HCLOUD_TOKEN variable

### Documentation

- Update documentation to include floating IPs
- Add example for running custom scripts with cloud-init
- Add link to channel list
- List related projects
- Add more debugging tools
- Increase server type
- Add warning to pod IP network configuration
- Add maintenance tasks and additional docs
- Add more tasks, add special thanks section
- Add features section
- Update node pool feature description
- Correct reference to hcloud_token variable

### Features

- Add feature to create floating IPs
- Use internal network for cluster networking
- Add feature to run scripts with cloud-init
- Add more type information
- Output IPv6 addresses
- Add Nürnberg datacenter and location
- Set hcloud version
- Adds firewall configuration
- Replace csi/ccm manifests with links to upstream
- Add support for k3s_version
- Update to version 1.32.2
- Add variable to specify version
- Replace flannel to support network policies
- Make installation optional
- Prevent deletion of servers and ignore user_data changes
- [**breaking**] Add support for multiple control plane nodes
- Make taint and additional initialization options configurable
- [**breaking**] Disable prevent destroy to improve usability
- [**breaking**] Change storage class' reclaim policy to Retain
- [**breaking**] Overhaul and simplify configuration
- Add cost calculation
- Make script wait until SSH connection is possible
- Add kured reboot daemon
- Add release task

### Miscellaneous Tasks

- Update hetzner addon manifests
- Reduce modules by putting the configuration in /, similar to k-andy
- Bump hcloud version
- Correct name of pool file
- Remove last references to the load balancer
- Add labels also to nodes
- Ignore control plane user data file
- Remove unused control_plane file
- Update module source reference
- Move update command to into a local variable
- Install ccm and csi via helm
- [**breaking**] Change control plane taint to node-role.kubernetes.io/control-plane
- Remove unused ip_offset variable
- [**breaking**] Make ccm and csi mandatory, correct name of chart version vars
- Add commit linter and nix package references
- Bump version

### README.md

- Mention that the script requires jq

### Refactor

- Replace template_file with templatefile

### Styling

- Correct markdownlint errors
- Reindent configuration code

<!-- generated by git-cliff -->
