# Changelog

All notable changes to this project will be documented in this file.

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

- Adds firewall configuration
- Add feature to create floating IPs
- Use internal network for cluster networking
- Add feature to run scripts with cloud-init
- Add more type information
- Output IPv6 addresses
- Add Nürnberg datacenter and location
- Set hcloud version
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
