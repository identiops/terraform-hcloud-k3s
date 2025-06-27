# Changelog

All notable changes to this project will be documented in this file.

## [6.2.0] - 2025-06-27

### Added Features

- [7d40ee6](https://github.com/identiops/terraform-hcloud-k3s/commit/7d40ee6dbff7aec5ca083d71dea54235f16692f0) Enabled embedded registry and add registries.yaml configuration

### Documentation

- [bea8357](https://github.com/identiops/terraform-hcloud-k3s/commit/bea835738d43c094fafa4ce4c6c826e0723a6c1b) Add configuration section

### Miscellaneous Tasks

- [632104a](https://github.com/identiops/terraform-hcloud-k3s/commit/632104a45f02f30b784765a9b3d749b0b595a8d0) Update cilium, hcloud-csi and hcloud-ccm

### Other

- [f6c768a](https://github.com/identiops/terraform-hcloud-k3s/commit/f6c768a0e3b430a0a290e086e39cc3be8daa3cfa) Update dependencies
- [0340ee2](https://github.com/identiops/terraform-hcloud-k3s/commit/0340ee2e0e6941d7d09953fce18596a902028a06) Update dependencies

## [6.1.2] - 2025-05-26

### Added Features

- [85001a7](https://github.com/identiops/terraform-hcloud-k3s/commit/85001a73b90ef4aa28d48e92e8bb83703d6841b2) Enable sysctl configuration via sysctl_settings variable

### Bug Fixes

- [d4b3485](https://github.com/identiops/terraform-hcloud-k3s/commit/d4b348505c691c80ae25b1866d03cbeb3081a654) Correct regex to match server types #35
- [0558854](https://github.com/identiops/terraform-hcloud-k3s/commit/05588548bd8f8df65e3e9ff7680842c3ebc8c0b5) Correct computation of nodes

### Miscellaneous Tasks

- [be55d87](https://github.com/identiops/terraform-hcloud-k3s/commit/be55d87d9e36cf131eed592f0d64d7a03df665d3) Update chart versions

## [6.1.1] - 2025-04-09

### Bug Fixes

- [c67352b](https://github.com/identiops/terraform-hcloud-k3s/commit/c67352bf61032a174fa3c4673b7b3541872306a3) Pin CRD version

## [6.1.0] - 2025-04-07

### Miscellaneous Tasks

- [045c9e3](https://github.com/identiops/terraform-hcloud-k3s/commit/045c9e3aa6d7e4a3e92e94fc799d83563aad1749) Update hcloud-csi to 2.13.0
- [bee1c7a](https://github.com/identiops/terraform-hcloud-k3s/commit/bee1c7aef2624a71482cead149903c1cf57adae9) Update cliff configuration

## [6.0.1] - 2025-03-11

### Documentation

- [c0e9b33](https://github.com/identiops/terraform-hcloud-k3s/commit/c0e9b33414ae485d558d8af342815d76dcf46675) Don't remove newlines in variable description

### Miscellaneous Tasks

- [47c4d6a](https://github.com/identiops/terraform-hcloud-k3s/commit/47c4d6a4e0bcaf37fe3d222788f75143e9538918) Correct link to system-upgrade-controller chart
- [2dc9920](https://github.com/identiops/terraform-hcloud-k3s/commit/2dc9920d5d58205f7d425ab3a2df3039de6c9d8a) Install system-upgrade-controller CRDs before helmchart

## [6.0.0] - 2025-03-10

### Bug Fixes

- [1769a17](https://github.com/identiops/terraform-hcloud-k3s/commit/1769a17b6fb86586adf29ef07fb149d579aec8e9) Rename hcloud-volumes to hcloud-volumes-retain and correct setting reclaim policy
- [**breaking**] [e1783b2](https://github.com/identiops/terraform-hcloud-k3s/commit/e1783b20f9faff455f1f5990f76cf6d7f12bb598) Correct and optimize configuration, esp. replace kube-proxy

### Miscellaneous Tasks

- [29b9339](https://github.com/identiops/terraform-hcloud-k3s/commit/29b9339d831e02850bd4a9af7b64b6fb7cb64cb3) Correct typos
- [cc204e5](https://github.com/identiops/terraform-hcloud-k3s/commit/cc204e5e7c8c0fb1e33f2ddeaac4d2d97fc637dc) Update kured to version 5.6.1
- [a5c9670](https://github.com/identiops/terraform-hcloud-k3s/commit/a5c96706c0c0d01bb77b0141498435958e4611f6) Disable kube-proxy and disable k3s helm-controller

## [5.0.0] - 2025-03-03

### Bug Fixes

- [**breaking**] [a947b74](https://github.com/identiops/terraform-hcloud-k3s/commit/a947b744228bb270411b8674e07e7e9c977800fe) Correct cilium installation that was broken when more than 1 node was part of the cluster

### Documentation

- [bfb23c5](https://github.com/identiops/terraform-hcloud-k3s/commit/bfb23c5164ce5e35a6f3c4cc35b3f6624260355e) Correct typos

## [4.2.1] - 2025-03-03

### Documentation

- [f512149](https://github.com/identiops/terraform-hcloud-k3s/commit/f512149e7c4f71472b57394ff2d2851dca30b121) Add link to OpenTofu registry and update ToC

## [4.2.0] - 2025-03-03

### Miscellaneous Tasks

- [36752a1](https://github.com/identiops/terraform-hcloud-k3s/commit/36752a1743031876aa8e9606dadd4e1d1c079bf8) Open cilium hubble port 4244 on all nodes

## [4.1.3] - 2025-02-28

### Documentation

- [ac6b4fd](https://github.com/identiops/terraform-hcloud-k3s/commit/ac6b4fdb3811c9a8891dd5cacf47ba0cbf8be65e) Correct typos

### Miscellaneous Tasks

- [e3bbbee](https://github.com/identiops/terraform-hcloud-k3s/commit/e3bbbeef42071edbcf868efe25ea9733038006c8) Add gateway configuration
- [2d0eb7b](https://github.com/identiops/terraform-hcloud-k3s/commit/2d0eb7b0c41266d35d572410d6675c6b2295f84d) Update to version 1.17.1

## [4.1.2] - 2025-02-12

### Documentation

- [da50e74](https://github.com/identiops/terraform-hcloud-k3s/commit/da50e7446d10a7259ca9fd0e329c671e567b2cda) Describe how to use the kubeapi jump host configuration
- [a857d5e](https://github.com/identiops/terraform-hcloud-k3s/commit/a857d5e842d9d1c71c5dae7a7dd769ff9783150e) Move kubeapi docs do maintenance section
- [3bfae7f](https://github.com/identiops/terraform-hcloud-k3s/commit/3bfae7fd42e1a124335d831c06fdd940af72f612) Add an upgrade plan example

### Miscellaneous Tasks

- [c6d7584](https://github.com/identiops/terraform-hcloud-k3s/commit/c6d758492ba11c81b32b7d76f57788d84b54b1c3) Update system-upgrade-controller to version 105.0.1
- [5f6276a](https://github.com/identiops/terraform-hcloud-k3s/commit/5f6276a919ba884c34397e7b75834fcd60233971) Update system-upgrade-controller configuration
- [1c6fadb](https://github.com/identiops/terraform-hcloud-k3s/commit/1c6fadb186cb060dc95399a17c6851d9a117c0c3) Add ssh port-forwarding configuration

## [4.1.1] - 2025-02-11

### Added Features

- [4554de6](https://github.com/identiops/terraform-hcloud-k3s/commit/4554de6d5dae4f75ab7bd1041c791d8b4cfab707) Add kubeapi jump account on gateway

## [4.1.0] - 2025-02-11

### Added Features

- [bcc5662](https://github.com/identiops/terraform-hcloud-k3s/commit/bcc5662b0a95d3665ca65aceab2c29869b320c22) Support different network interface names depending on OS image

### Documentation

- [dc900fb](https://github.com/identiops/terraform-hcloud-k3s/commit/dc900fbea8cba63f5f72c95d39b943b44ae11f22) Add apple silicon warning #19

## [4.0.0] - 2025-02-10

### Bug Fixes

- [0c67955](https://github.com/identiops/terraform-hcloud-k3s/commit/0c6795517cae77d37d024c99fec65727d4605677) Link to simple example in README
- [b4b1ccb](https://github.com/identiops/terraform-hcloud-k3s/commit/b4b1ccb80b364ef12939e1602bb428ee4384149b) Drop template dependency
- [2d53b44](https://github.com/identiops/terraform-hcloud-k3s/commit/2d53b443c535e269391a470fd314f85c28088a21) Change default node type to an existing type and validate node type in pools #11

### Documentation

- [1a6ddb2](https://github.com/identiops/terraform-hcloud-k3s/commit/1a6ddb253d584778b319c4fc79ad1c28fd452adf) Fix topy
- [5a406b7](https://github.com/identiops/terraform-hcloud-k3s/commit/5a406b760421669def208083f57b9e2f3f907862) Emphasize that the kubectl command is executed locally #13

### Miscellaneous Tasks

- [924d6e6](https://github.com/identiops/terraform-hcloud-k3s/commit/924d6e604b714c15e49cf9279b37197fe3df435e) Lift required version to 0.12.0
- [cc0a5c3](https://github.com/identiops/terraform-hcloud-k3s/commit/cc0a5c354ca2af778987e68f5a7ebea94b1b9027) Update dependencies
- [2d44b9f](https://github.com/identiops/terraform-hcloud-k3s/commit/2d44b9fbbcd3b28aff156e0f53120f6ef8902a03) Cleanup links
- [01573d1](https://github.com/identiops/terraform-hcloud-k3s/commit/01573d1a34c878c7a9fa5b9a63e2b4c9432c0dde) Increase time to live for upgrade jobs
- [70357b4](https://github.com/identiops/terraform-hcloud-k3s/commit/70357b4c3d7c523fd89b74ba9837303627affd7c) Update dependencies
- [ab39cb9](https://github.com/identiops/terraform-hcloud-k3s/commit/ab39cb943f30e5ec0806dc287fd75f5cf294969a) Update terraform versions
- [**breaking**] [e1ce382](https://github.com/identiops/terraform-hcloud-k3s/commit/e1ce382508e7a72b846ea7a90768efc4f5be19ca) Update ubuntu version to 24.04 and update dependencies #12

## [3.0.6] - 2024-03-18

### Added Features

- [46bdd5f](https://github.com/identiops/terraform-hcloud-k3s/commit/46bdd5f5571e6ecd78f5df9dff4510039018aa0a) Make ICMP and kubernetes configurable in firewall

### Documentation

- [b9b5ee7](https://github.com/identiops/terraform-hcloud-k3s/commit/b9b5ee73404c5b4b0f74ab2e57aafc6be88f58a0) Add reference to kube-hetzner

## [3.0.5] - 2024-02-19

### Documentation

- [bd1b142](https://github.com/identiops/terraform-hcloud-k3s/commit/bd1b142f44fcfa42d4eb282d93054a3ef9cd4c67) Correct links in toc

## [3.0.4] - 2024-02-19

### Added Features

- [33ca9d2](https://github.com/identiops/terraform-hcloud-k3s/commit/33ca9d22920560d54a52852025638c68a2f586d2) Perform dist-upgrade after initializing the cluster

## [3.0.3] - 2024-02-19

### Added Features

- [334501b](https://github.com/identiops/terraform-hcloud-k3s/commit/334501b55f5c3ed0c73ccd18441aed06658c15a9) Move component versions into module to simplify examples

### Documentation

- [67d55fc](https://github.com/identiops/terraform-hcloud-k3s/commit/67d55fc336bcac751071f3ab46ef4bc0626f5a92) Add helm and cilium as recommended tools
- [f6e3592](https://github.com/identiops/terraform-hcloud-k3s/commit/f6e3592000af60deb23c3bba06667008064732cb) Add detailed component update instructions

## [3.0.2] - 2024-02-17

### Documentation

- [a1293c0](https://github.com/identiops/terraform-hcloud-k3s/commit/a1293c0938badfaded2b3fff156788f70ab13aa0) Add k9s screenshot

## [3.0.1] - 2024-02-17

### Documentation

- [ad72ba4](https://github.com/identiops/terraform-hcloud-k3s/commit/ad72ba4c98f43634eb591801320867c2b9327dd7) Add an additional installation step

## [3.0.0] - 2024-02-17

### Added Features

- [5dc4f01](https://github.com/identiops/terraform-hcloud-k3s/commit/5dc4f0180690f9f4e5b3113f212132cbdbbe81d7) Add local haproxy to all nodes to get high availibility

### Bug Fixes

- [9531ad3](https://github.com/identiops/terraform-hcloud-k3s/commit/9531ad39edc50826c6e862db73da27127c2c1e52) Hide virtual `*` host

### Documentation

- [f12a7d3](https://github.com/identiops/terraform-hcloud-k3s/commit/f12a7d3ff84e0b52f39ae4297a78057b3b0811cb) Add more figures
- [8d126cd](https://github.com/identiops/terraform-hcloud-k3s/commit/8d126cd95a9e4727a95c10ffee92b5dab591f0b4) Correct reference to pictures

### Miscellaneous Tasks

- [19a1252](https://github.com/identiops/terraform-hcloud-k3s/commit/19a12527a2635eeaea34e104ddfca4cb5df495d4) Make nu shell version configurable

## [2.6.0] - 2024-02-16

### Added Features

- [09d259c](https://github.com/identiops/terraform-hcloud-k3s/commit/09d259c825a08631c5458452ae096f85490b0804) Install ccm earlier and set additional tolerations
- [605b5b1](https://github.com/identiops/terraform-hcloud-k3s/commit/605b5b136cd602bea2be3529453b77b3facf74eb) Set k8sServiceHost to load balancer

### Miscellaneous Tasks

- [e29fac7](https://github.com/identiops/terraform-hcloud-k3s/commit/e29fac703d13b6f75086d95e587b595ee019ce6c) Add infrastructure image source
- [0f4669e](https://github.com/identiops/terraform-hcloud-k3s/commit/0f4669ef2ccd11415bad5c8ca66c66fce8ca8b05) Migrate to system-upgrade-controller helm chart

## [2.5.3] - 2024-02-08

### Added Features

- [8d65a9a](https://github.com/identiops/terraform-hcloud-k3s/commit/8d65a9a2f6a150f737edb766e9d4236cc4e6ef09) Display net and gross with a precision of 2
- [0880158](https://github.com/identiops/terraform-hcloud-k3s/commit/088015830ba8758ec7a872819fb209d92a319d03) Make count width in node names configurable

## [2.5.1] - 2024-02-08

### Added Features

- [516f469](https://github.com/identiops/terraform-hcloud-k3s/commit/516f469f95e92d11d2f7117ec9152d7463e84718) Use read only token to fetch prices
- [d8ce7e6](https://github.com/identiops/terraform-hcloud-k3s/commit/d8ce7e60739447427f0a705e5995e9c13644b4f8) Add multi-region example and improve default example

### Documentation

- [1dd8cb3](https://github.com/identiops/terraform-hcloud-k3s/commit/1dd8cb3a69ad8469bff30f57674da87330162227) Add link to the example
- [0a2d49d](https://github.com/identiops/terraform-hcloud-k3s/commit/0a2d49dac6ace515e70ff48bc1602eb8d1eab45e) Name load balancing challenges when zone outages occur

## [2.5.0] - 2024-02-07

### Added Features

- [26f01bc](https://github.com/identiops/terraform-hcloud-k3s/commit/26f01bc8b4de75f6ca3a7c52421da7196e55381a) Add support for multi-region deployments
- [a150542](https://github.com/identiops/terraform-hcloud-k3s/commit/a15054207e03e7766b67d445514f38e5b9fa27ab) Support image configuration per node pool
- [5625c58](https://github.com/identiops/terraform-hcloud-k3s/commit/5625c58fe7979fcbb1ae977bc116989b2f81292c) Make network zone configurable

### Documentation

- [b1955dc](https://github.com/identiops/terraform-hcloud-k3s/commit/b1955dc44291b9d7e8c7dd4b0bee43612accc2e9) Correct typos
- [07e07dc](https://github.com/identiops/terraform-hcloud-k3s/commit/07e07dc16d5a767fb81b4919d53028296ef0a9ce) Quote ansible variable contents

### Miscellaneous Tasks

- [2fa99aa](https://github.com/identiops/terraform-hcloud-k3s/commit/2fa99aa8b2ccbdfd89b535d1e4338e64324c2a1a) Ignore ansible inventory
- [1d75574](https://github.com/identiops/terraform-hcloud-k3s/commit/1d7557444e3b695d3a1b9d445d5e3ee53258ee57) Update version constraints

## [2.4.0] - 2024-02-02

### Added Features

- [c494c87](https://github.com/identiops/terraform-hcloud-k3s/commit/c494c87513513444d3401ff889debef01e1189d6) Add links to charts

### Bug Fixes

- [5d76b7e](https://github.com/identiops/terraform-hcloud-k3s/commit/5d76b7ef0437b3f0d962cd00346ff9ace406249d) Open all relevant kubernetes ports in the firewall
- [73b8e21](https://github.com/identiops/terraform-hcloud-k3s/commit/73b8e218307ae2330428d3c32ff4c5d2ef36acf8) Make kubectl exec and logs commands work

### Documentation

- [0213cc5](https://github.com/identiops/terraform-hcloud-k3s/commit/0213cc584f9b4008fb32ae8decfbee24e4576360) Add ansible integration as feature
- [506c9ba](https://github.com/identiops/terraform-hcloud-k3s/commit/506c9ba7f44255a2c99393be24863b028c9e309d) Add examples to verify cilium and cluster configuration
- [07d34af](https://github.com/identiops/terraform-hcloud-k3s/commit/07d34af3d5e514ca29293e39573451eb6585869a) Describe how to add an ingress controller
- [062619e](https://github.com/identiops/terraform-hcloud-k3s/commit/062619e33221d63e830f543c11dc9ff2839e2833) Add table of contents
- [f2714e2](https://github.com/identiops/terraform-hcloud-k3s/commit/f2714e2c369c977d1714f601cdba26a1ccd4d03f) Add references to updating additional components

## [2.3.7] - 2024-02-01

### Added Features

- [22db797](https://github.com/identiops/terraform-hcloud-k3s/commit/22db797732080e6c77d04b5b9181fb2a6574404e) Auto-generate ansible inventory and describe usage

### Miscellaneous Tasks

- [5df3a6d](https://github.com/identiops/terraform-hcloud-k3s/commit/5df3a6d5fd9727be708a4d70423539ce76630006) Add warning to auto-generated files

## [2.3.6] - 2024-01-30

### Documentation

- [09df023](https://github.com/identiops/terraform-hcloud-k3s/commit/09df02377d0aac4e41ef1a0e450774d7f85c67fb) Add anchor to the getting started guide

## [2.3.5] - 2024-01-30

### Documentation

- [d6e040d](https://github.com/identiops/terraform-hcloud-k3s/commit/d6e040d6ae31258fc83e78f9c611a5d74396cb60) Add instructions for using the example

## [2.3.4] - 2024-01-30

### Documentation

- [18e888d](https://github.com/identiops/terraform-hcloud-k3s/commit/18e888d756a93e896dbb58077b376f9ec2d418a5) Rename Debugging section to Troubleshooting
- [abe6425](https://github.com/identiops/terraform-hcloud-k3s/commit/abe64254c4ebbbdfeb8a6df85458abb7b29ef98a) Place examples in subfolder so they're found by the registry

## [2.3.3] - 2024-01-29

### Bug Fixes

- [bbe2c26](https://github.com/identiops/terraform-hcloud-k3s/commit/bbe2c26261006e918ae885296363077b49729ac1) Pass only the read only token to the gateway script

## [2.3.2] - 2024-01-28

### Documentation

- [93028b8](https://github.com/identiops/terraform-hcloud-k3s/commit/93028b8122ebaf01d90d8cd617df5696889f5381) Correct spelling

## [2.3.1] - 2024-01-28

### Bug Fixes

- [4edf739](https://github.com/identiops/terraform-hcloud-k3s/commit/4edf739eadc55b040798b0ebb7623d6fb657c7d5) Correct null error when retrieving gateway labels

## [2.3.0] - 2024-01-28

### Added Features

- [00998d4](https://github.com/identiops/terraform-hcloud-k3s/commit/00998d4317aa9ad02bd4971cfdb4f476bf41d836) Require a second read only access token for the gateway

## [2.2.0] - 2024-01-28

### Added Features

- [35aa5b6](https://github.com/identiops/terraform-hcloud-k3s/commit/35aa5b6bed692b8796c98825d339f311270804f7) Make resources immune to changes to cluster_name
- [0c1e39d](https://github.com/identiops/terraform-hcloud-k3s/commit/0c1e39da5d61757088bd5785fe0a9a4fd461c9cc) Add image and location information to output

### Bug Fixes

- [05ddabc](https://github.com/identiops/terraform-hcloud-k3s/commit/05ddabca7914bcf2cfed4a717b94167fb4001ab4) Restore the life cycle ignore settings for image and location
- [a6cd077](https://github.com/identiops/terraform-hcloud-k3s/commit/a6cd077f5b26c31cac6efeed60f222649b7d80ac) Remove KUBECONFIG setting from scripts

### Documentation

- [4b12232](https://github.com/identiops/terraform-hcloud-k3s/commit/4b12232d0cd62139442fb33a3708ecf77f35f362) Clarify OS upgrade instructions
- [f786ea8](https://github.com/identiops/terraform-hcloud-k3s/commit/f786ea81a921024c6a0946739f9396142774e258) Clarify installation instructions and rework feature list

### Miscellaneous Tasks

- [233c8f7](https://github.com/identiops/terraform-hcloud-k3s/commit/233c8f7b7ae98e515914edd90f2ac93c7ba75869) Improve SSH example configuration

## [2.1.1] - 2024-01-27

### Added Features

- [b6ca0ce](https://github.com/identiops/terraform-hcloud-k3s/commit/b6ca0ce00fa0fbb4454aeee7e538e9c0f95a62b1) Add s3 backend and etcd snapshot configuration

### Bug Fixes

- [8a2fa33](https://github.com/identiops/terraform-hcloud-k3s/commit/8a2fa331ff5cb901c0cd7bf6543b2705ae829cee) Add missing opentofu dependency

## [2.1.0] - 2024-01-27

### Added Features

- [eca707e](https://github.com/identiops/terraform-hcloud-k3s/commit/eca707e2bc29d75a325b66165f07f4f45686a77b) Replace sleep wait with cluster readiness check script

### Documentation

- [d784a0c](https://github.com/identiops/terraform-hcloud-k3s/commit/d784a0ccf2ba83bb7b29fddfda8c04263d99f40c) Remove warning about hard coded gateway
- [512ddbc](https://github.com/identiops/terraform-hcloud-k3s/commit/512ddbc240d0a2b53203680b7c352e62d77d117d) Simplify instructions for OS upgrades of the main node pool

### Miscellaneous Tasks

- [5d6dd53](https://github.com/identiops/terraform-hcloud-k3s/commit/5d6dd5307f9d5c36c5aee875a282dc5821fe10bf) Update copyright and add license identifiers to files

## [2.0.5] - 2024-01-26

### Documentation

- [35a7b2e](https://github.com/identiops/terraform-hcloud-k3s/commit/35a7b2e441af9e3953986dab661147f1bae01f30) Remove last bit of s3 configuration

## [2.0.4] - 2024-01-26

### Miscellaneous Tasks

- [aa6cad6](https://github.com/identiops/terraform-hcloud-k3s/commit/aa6cad63848443dc7050dd341b850c33f77bc7b3) Remove s3 sample configuation

## [2.0.3] - 2024-01-26

### Documentation

- [2126152](https://github.com/identiops/terraform-hcloud-k3s/commit/21261520dc8074e1fe2b80023faa6868615c8f22) Update infrastructure picture

## [2.0.2] - 2024-01-26

### Documentation

- [54c37ea](https://github.com/identiops/terraform-hcloud-k3s/commit/54c37eadb39478542b9658fd88442b1712fbff8b) Add link to github stars counter

## [2.0.1] - 2024-01-26

### Documentation

- [4ed9325](https://github.com/identiops/terraform-hcloud-k3s/commit/4ed93252251efcbec2d39796107eb8c2e8843247) Cleanup links

## [2.0.0] - 2024-01-26

### Added Features

- [2d523a7](https://github.com/identiops/terraform-hcloud-k3s/commit/2d523a75837844a2eae34700ceba86796d8ac31c) Install metrics server via helm
- [**breaking**] [6345ed9](https://github.com/identiops/terraform-hcloud-k3s/commit/6345ed9108ed7d6c813a655a7185679a6512f078) Integrate control_plane_main into node_pools

### Documentation

- [be9c8f7](https://github.com/identiops/terraform-hcloud-k3s/commit/be9c8f7267f7edd124c9b5a3b70ce55181960357) Correct typos and add hcloud-k3s reference

### Miscellaneous Tasks

- [b29495a](https://github.com/identiops/terraform-hcloud-k3s/commit/b29495aa91b4052035a8d6d25b85b15cc02eacd7) Add validation for node_pools
- [2ac35b7](https://github.com/identiops/terraform-hcloud-k3s/commit/2ac35b74d974a9006ecf6414a74f6812f829f03f) Replace hard-coded default gateway with a dynamic calculation
- [d9eb3fc](https://github.com/identiops/terraform-hcloud-k3s/commit/d9eb3fc48a451c61de27534668218fb119cd1db6) Reorder firewall rules in gateway
- [0a7ee7a](https://github.com/identiops/terraform-hcloud-k3s/commit/0a7ee7a6acc8e48835cf8b0ca8cebb5a730e9f20) Manage all scripts in scripts.tf
- [a1c6f47](https://github.com/identiops/terraform-hcloud-k3s/commit/a1c6f47ccb5353f738c5d5dcfc31f24441a34632) Use terraform registry module as the default source

## [1.0.0] - 2024-01-24

### Added Features

- [01ab5a6](https://github.com/identiops/terraform-hcloud-k3s/commit/01ab5a677e89f03c3feec22157acf87e002c11fa) Use haproxy on gateway to proxy port 6443
- [738551a](https://github.com/identiops/terraform-hcloud-k3s/commit/738551af39e571007a7edb5d1cc8db7f1cc522c2) Show ports and protocols in architecture picture
- [4b082e3](https://github.com/identiops/terraform-hcloud-k3s/commit/4b082e30db9b4cf27d5c4abcfa75cd3e2fca236d) Add node_count to pools and total costs output and optimize label output

### Bug Fixes

- [cddea72](https://github.com/identiops/terraform-hcloud-k3s/commit/cddea7246ae8287872e7d7c1c2634588f9664cc8) Add missing k3s --cloud-init switch

### Documentation

- [80f4647](https://github.com/identiops/terraform-hcloud-k3s/commit/80f4647fff3c5cef42ae3341ecbff5692b6deba1) Shorten link to terraform module
- [aaa7064](https://github.com/identiops/terraform-hcloud-k3s/commit/aaa7064693fcbec068f7b9bd5253d50abb15acae) Make runcmd debugging use sh -e
- [9e3c1bd](https://github.com/identiops/terraform-hcloud-k3s/commit/9e3c1bd10db241854ff196e18c4346beb0562706) Reorder documentation
- [4540d60](https://github.com/identiops/terraform-hcloud-k3s/commit/4540d60e44747e4f731ad2e7194a2ef7eaf94ea6) Document load balancer annotations
- [6c50f38](https://github.com/identiops/terraform-hcloud-k3s/commit/6c50f384e9fad04e6bb3fa9cc2ff476fdc5fab48) Add a to be added section
- [44fa0f4](https://github.com/identiops/terraform-hcloud-k3s/commit/44fa0f454e983ed4a5a4ae8f5ad40722c87a5857) Add changelog reference

### Miscellaneous Tasks

- [9574782](https://github.com/identiops/terraform-hcloud-k3s/commit/9574782b7bbfaff61237cbb55ef8e602e05eb5b1) Remove mandatory newline
- [41308a3](https://github.com/identiops/terraform-hcloud-k3s/commit/41308a320351018b3e05d0b41b5527a3b1542e34) Change schedule to start at 1am
- [1963470](https://github.com/identiops/terraform-hcloud-k3s/commit/19634703cea9231669ac824626871364830be64e) Change no workload taint back to CriticalAddonsOnly
- [044e240](https://github.com/identiops/terraform-hcloud-k3s/commit/044e24000e0f144e1700317e74e627c2c29f4dd3) Update description and lower suggested node size

## [0.2.0] - 2024-01-23

### Bug Fixes

- [2da37e6](https://github.com/identiops/terraform-hcloud-k3s/commit/2da37e6951282f0a1e76b2068adefd052838c958) Syntax error in installation scirpt

### Documentation

- [5e842d8](https://github.com/identiops/terraform-hcloud-k3s/commit/5e842d81aedd634cd2b222da97900e333c63b43f) Improve k8s upgrade

## [0.1.5] - 2024-01-23

### Added Features

- [47879fd](https://github.com/identiops/terraform-hcloud-k3s/commit/47879fd20bf072847ae3c5fcc15bcb8708aa4542) Add variable for passing k3s options to main server
- [8759b5c](https://github.com/identiops/terraform-hcloud-k3s/commit/8759b5c2c6898e573a72947572d56f1915ed8657) Ignore changes to server ssh_keys and location
- [dd58093](https://github.com/identiops/terraform-hcloud-k3s/commit/dd58093c2b037e2c7fe595bb042acbaec8ac3ff1) Add and document restore and os upgrades
- [b24d74c](https://github.com/identiops/terraform-hcloud-k3s/commit/b24d74ccbbf2993c5c3c6f79ddc5a76a0db165b5) Apply and document security hardening
- [e413b44](https://github.com/identiops/terraform-hcloud-k3s/commit/e413b44394f0fb73c0565f4eb8398ae13f6eca0e) Add system upgrade controller

### Documentation

- [815e708](https://github.com/identiops/terraform-hcloud-k3s/commit/815e70886a93ec720f6a6dec94409819a22d6c7b) Update output descriptions
- [2cfb128](https://github.com/identiops/terraform-hcloud-k3s/commit/2cfb128dafe3108110081f6fcc9e405927cbd102) Add badges and link to terraform registry
- [e9f89b6](https://github.com/identiops/terraform-hcloud-k3s/commit/e9f89b67ef5c09937961b2529aad6472398f01ec) List more features
- [e2e19b1](https://github.com/identiops/terraform-hcloud-k3s/commit/e2e19b100833a0571c5a3c96a66b89ed002f831f) Remove duplicated section Addons included

### Miscellaneous Tasks

- [ae53070](https://github.com/identiops/terraform-hcloud-k3s/commit/ae530706f44358800cc3ee20355c71c3c9525f01) Allow inbound ICMP
- [ecb28ad](https://github.com/identiops/terraform-hcloud-k3s/commit/ecb28ad7c98c2edfeb33a9b32209f1f2a1546f69) Prefix firewall with cluster name
- [678cb41](https://github.com/identiops/terraform-hcloud-k3s/commit/678cb418d05d88ecf627702eb39dc63f5b63f011) Remove local cloud init file

### Refactor

- [b9b602b](https://github.com/identiops/terraform-hcloud-k3s/commit/b9b602bb700265bcc5702de92dec8c67fe9cefcc) Group all setup commands

## [0.1.4] - 2024-01-23

### Documentation

- [4c8d2ac](https://github.com/identiops/terraform-hcloud-k3s/commit/4c8d2ac6a434fe2399c2a93588521e3bac84643a) Make references absolute to work on registry.terraform.io

## [0.1.3] - 2024-01-23

### Added Features

- [cab0481](https://github.com/identiops/terraform-hcloud-k3s/commit/cab048100b0db86c90d6b153c1b60e813d9f2384) Add feature to create floating IPs
- [af0a522](https://github.com/identiops/terraform-hcloud-k3s/commit/af0a522f18cb99328b9f7d09ea2470cacf9cc72f) Use internal network for cluster networking
- [bdda15e](https://github.com/identiops/terraform-hcloud-k3s/commit/bdda15eb6919c812a7dff848d2b0dd77d2a3ffe6) Add feature to run scripts with cloud-init
- [8fc35f7](https://github.com/identiops/terraform-hcloud-k3s/commit/8fc35f7b15bebbcd78b8b4773bf1dd2484fb3da8) Add more type information
- [465f823](https://github.com/identiops/terraform-hcloud-k3s/commit/465f8231887af940faf52c3c0233dbcdb1addf40) Output IPv6 addresses
- [ea36209](https://github.com/identiops/terraform-hcloud-k3s/commit/ea3620991be38c377ec0a998011b7fbed1e5e453) Add Nürnberg datacenter and location
- [bc6b129](https://github.com/identiops/terraform-hcloud-k3s/commit/bc6b12910e49fdc77e2bb3fb8d7ad57749aed164) Set hcloud version
- [6be3f00](https://github.com/identiops/terraform-hcloud-k3s/commit/6be3f00542357245750cf9fe242af7af2154d264) Adds firewall configuration
- [131dfaa](https://github.com/identiops/terraform-hcloud-k3s/commit/131dfaa9744fe77bce23dc9677ffaaf89c0eaf85) Replace csi/ccm manifests with links to upstream
- [9c1fcbc](https://github.com/identiops/terraform-hcloud-k3s/commit/9c1fcbc715c71d739a42398d86b4a51ea85fcceb) Add support for k3s_version
- [c511a1c](https://github.com/identiops/terraform-hcloud-k3s/commit/c511a1cf14dc893b4312c32f1c563d3a04b0d70c) Update to version 1.32.2
- [5604640](https://github.com/identiops/terraform-hcloud-k3s/commit/56046406b37276818405b47a6474d0f9748f5079) Add variable to specify version
- [e98776b](https://github.com/identiops/terraform-hcloud-k3s/commit/e98776ba62ae353d5b78b7ba24759a26b5fb2af4) Replace flannel to support network policies
- [c7110ef](https://github.com/identiops/terraform-hcloud-k3s/commit/c7110effd35b020dbd8b87d7c9bdd6b9c49400fb) Make installation optional
- [d755d1b](https://github.com/identiops/terraform-hcloud-k3s/commit/d755d1b5d72a9a8c219ec13c37a54bd99138e97c) Prevent deletion of servers and ignore user_data changes
- [**breaking**] [261cd0f](https://github.com/identiops/terraform-hcloud-k3s/commit/261cd0ff9dc6e9d14351c3cddca54677744f5282) Add support for multiple control plane nodes
- [a5a5a50](https://github.com/identiops/terraform-hcloud-k3s/commit/a5a5a504d9f74e308f4ff59f2182f735915dc2ae) Make taint and additional initialization options configurable
- [**breaking**] [303edae](https://github.com/identiops/terraform-hcloud-k3s/commit/303edae8e77fba85d45797b960853c0e0326786d) Disable prevent destroy to improve usability
- [**breaking**] [1d587b0](https://github.com/identiops/terraform-hcloud-k3s/commit/1d587b0c8eddfcafd2b9ba57575438e9bbdf0329) Change storage class' reclaim policy to Retain
- [**breaking**] [88ec862](https://github.com/identiops/terraform-hcloud-k3s/commit/88ec862272b50c2c0e7f19942c81801fc8a89cab) Overhaul and simplify configuration
- [8a81f84](https://github.com/identiops/terraform-hcloud-k3s/commit/8a81f84683cd103fc89b7d7638a8aac0d48ba87b) Add cost calculation
- [3a756b8](https://github.com/identiops/terraform-hcloud-k3s/commit/3a756b83a4d9e40c27eae3765f81b2438ec7ad57) Make script wait until SSH connection is possible
- [f263e30](https://github.com/identiops/terraform-hcloud-k3s/commit/f263e302f20e7b4abca8ea216890a9ade8ec7e09) Add kured reboot daemon

### Bug Fixes

- [670eecc](https://github.com/identiops/terraform-hcloud-k3s/commit/670eecc7a0f7f2e1dde7861aaf2d96a8f4f470cb) Correct apiVersion of kustomization
- [6da6cd6](https://github.com/identiops/terraform-hcloud-k3s/commit/6da6cd671d5f69fedfafd870e17e84c1f4532228) Reactivate flannel
- [dd234e4](https://github.com/identiops/terraform-hcloud-k3s/commit/dd234e4d4f76497f6ee2409fa63d1033a208fb2f) Reenable calico and correct network configuration
- [a324a37](https://github.com/identiops/terraform-hcloud-k3s/commit/a324a37e1b7064d71e130175cbfe51b984049860) Disable batch mode, it fails for proxied connections
- [5e1275d](https://github.com/identiops/terraform-hcloud-k3s/commit/5e1275d4ae5f6a2aab793ca69ce127f36a1c1379) Correct workload scheduling variable meaning
- [7551b6b](https://github.com/identiops/terraform-hcloud-k3s/commit/7551b6b0fc9d912ce738834e4056f336e9e9085e) Disable IPv6 to make calico work
- [a1622cb](https://github.com/identiops/terraform-hcloud-k3s/commit/a1622cb2c260e055a0f73ff8a8cec5816fd6777b) Disable bgp
- [86cb926](https://github.com/identiops/terraform-hcloud-k3s/commit/86cb926569cc54564a76aeb25ba9378ba3efb198) Remove k8s firewall rules from gateway
- [0ffe712](https://github.com/identiops/terraform-hcloud-k3s/commit/0ffe7121b764389c2ebd7bf98a167f5c0212a378) Add output of total monthly costs
- [8f7245c](https://github.com/identiops/terraform-hcloud-k3s/commit/8f7245c4a987a13150a111a300a95a1bab79bfc8) Replace calico with cilium
- [987ca7f](https://github.com/identiops/terraform-hcloud-k3s/commit/987ca7f7d3394a6168ad9a152508c35f9304a816) Increase inotify limits to make log streaming work
- [6992d00](https://github.com/identiops/terraform-hcloud-k3s/commit/6992d00cfc3687d91b460ceaebd8f509812c2fe8) Remove dependency on HCLOUD_TOKEN variable

### Documentation

- [54b78be](https://github.com/identiops/terraform-hcloud-k3s/commit/54b78befff23322646697594c1438b721f2c69ca) Update documentation to include floating IPs
- [0c2c13c](https://github.com/identiops/terraform-hcloud-k3s/commit/0c2c13c0e48820ba91d1a31c980e8459567aa759) Add example for running custom scripts with cloud-init
- [51937cb](https://github.com/identiops/terraform-hcloud-k3s/commit/51937cbddb61119c3de16692b594d8880a3e511e) Add link to channel list
- [5827009](https://github.com/identiops/terraform-hcloud-k3s/commit/58270090c05c4fac38abf214ab9cbe34dce5c9cd) List related projects
- [8dfd8ba](https://github.com/identiops/terraform-hcloud-k3s/commit/8dfd8bacfe561e4d05819cf4c16bad4608dcd521) Add more debugging tools
- [6481332](https://github.com/identiops/terraform-hcloud-k3s/commit/6481332ec9046a31883e0d1fa44c1354707da767) Increase server type
- [93f4aae](https://github.com/identiops/terraform-hcloud-k3s/commit/93f4aae8865eb58dd60a48b6009047b077ffcff0) Add warning to pod IP network configuration
- [dc05b1e](https://github.com/identiops/terraform-hcloud-k3s/commit/dc05b1ecf2d12735996899b05185db9c0609aee9) Add maintenance tasks and additional docs
- [138f18f](https://github.com/identiops/terraform-hcloud-k3s/commit/138f18f52cc9582befba0567cd1a75e470f793f0) Add more tasks, add special thanks section
- [0c9426b](https://github.com/identiops/terraform-hcloud-k3s/commit/0c9426b9586d1d774edfa5965a4e17ced4098ae7) Add features section
- [849c128](https://github.com/identiops/terraform-hcloud-k3s/commit/849c1285d18efc999a893b9f579ab1c47467aed8) Update node pool feature description
- [d9c23ae](https://github.com/identiops/terraform-hcloud-k3s/commit/d9c23ae8401afde2402bdc2454ac5bb0693e150a) Correct reference to hcloud_token variable

### Miscellaneous Tasks

- [b5599d5](https://github.com/identiops/terraform-hcloud-k3s/commit/b5599d5426b373567f087f84fc26493745d62d6d) Update hetzner addon manifests
- [efba796](https://github.com/identiops/terraform-hcloud-k3s/commit/efba796c5f110a2dff22a142e38ae892d89ab87b) Reduce modules by putting the configuration in /, similar to k-andy
- [906734f](https://github.com/identiops/terraform-hcloud-k3s/commit/906734f1a9674c6958e15668e07e990c69ef087a) Bump hcloud version
- [74a01ab](https://github.com/identiops/terraform-hcloud-k3s/commit/74a01aba3ab94791dde27cea86fa2b4561d3d298) Correct name of pool file
- [9760c1c](https://github.com/identiops/terraform-hcloud-k3s/commit/9760c1c602b1c8f50901364a55cfada6eb3e99ae) Remove last references to the load balancer
- [7e456e9](https://github.com/identiops/terraform-hcloud-k3s/commit/7e456e98544c1318f1cedc5451d63d4375549317) Add labels also to nodes
- [9757805](https://github.com/identiops/terraform-hcloud-k3s/commit/97578051f30c1b0f2e05645c871b807107da4dd9) Ignore control plane user data file
- [c93784f](https://github.com/identiops/terraform-hcloud-k3s/commit/c93784f548a8057a0eb4a6b35773121fe56decc4) Remove unused control_plane file
- [9346855](https://github.com/identiops/terraform-hcloud-k3s/commit/93468552c1d2769d2628e4be0361702452bc73ce) Update module source reference
- [857c6ec](https://github.com/identiops/terraform-hcloud-k3s/commit/857c6ec90e2663d737b715d969c59d40299ff8f4) Move update command to into a local variable
- [83aafc5](https://github.com/identiops/terraform-hcloud-k3s/commit/83aafc5ea72d33a0dfece96ad77a93049c3cad5b) Install ccm and csi via helm
- [**breaking**] [6ce40e9](https://github.com/identiops/terraform-hcloud-k3s/commit/6ce40e979cd9cbd4dfae1a62517c5fe6905f2660) Change control plane taint to node-role.kubernetes.io/control-plane
- [b311449](https://github.com/identiops/terraform-hcloud-k3s/commit/b311449174c76909e5605116828815f954867916) Remove unused ip_offset variable
- [**breaking**] [6c40498](https://github.com/identiops/terraform-hcloud-k3s/commit/6c4049802a4abd5e9b5f2a001a5b0c2354970808) Make ccm and csi mandatory, correct name of chart version vars
- [ee9b2c5](https://github.com/identiops/terraform-hcloud-k3s/commit/ee9b2c5f03d9168f60fdd6cd1f3d1ead99abbd9f) Bump version

### Other

- [1f98883](https://github.com/identiops/terraform-hcloud-k3s/commit/1f98883b01d1f5715dd4c5e2e0ba7ae4f477d559) Mention that the script requires jq

### Refactor

- [c921f2c](https://github.com/identiops/terraform-hcloud-k3s/commit/c921f2c003d32bedb85097d4ce63b7ecb88a7313) Replace template_file with templatefile

### Styling

- [22690a2](https://github.com/identiops/terraform-hcloud-k3s/commit/22690a239432c73ee856d87c3bceeb52a511e7e5) Correct markdownlint errors
- [7d80925](https://github.com/identiops/terraform-hcloud-k3s/commit/7d809255511f66f6121f465034d5f97fa74c1366) Reindent configuration code

<!-- generated by git-cliff -->
