resource "hcloud_server" "control_plane_main" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data, image]
  }
  depends_on = [time_sleep.wait_30_seconds]

  name               = "${var.cluster_name}-control-plane-main"
  delete_protection  = var.delete_protection
  rebuild_protection = var.delete_protection
  location           = var.location
  image              = var.image
  server_type        = var.control_plane_main_server_type
  ssh_keys           = [for k in hcloud_ssh_key.pub_keys : k.name]
  labels             = var.control_plane_main_labels
  # placement_group_id = hcloud_placement_group.control_plane.id
  user_data    = local.control_plane_main_user_data
  firewall_ids = var.control_plane_firewall_ids

  public_net {
    # ipv4_enabled = true # force control plane server to be exposed to the internet
    # ipv6_enabled = true
    ipv4_enabled = var.enable_public_net_ipv4
    ipv6_enabled = var.enable_public_net_ipv6
  }

  # Network needs to be present twice for some unknown reason :-/
  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, 2)
  }
}

resource "hcloud_server_network" "control_plane_main" {
  server_id  = hcloud_server.control_plane_main.id
  network_id = hcloud_network.private.id
  ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, 2)
}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [hcloud_server.gateway]
  create_duration = "30s"
}

locals {
  control_plane_main_user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
    # not sure if I need these settings now that the software installation is done later
    network = {
      version = 1
      config = [
        {
          type = "physical"
          name = "ens10"
          subnets = [
            { type    = "dhcp"
              gateway = "10.0.0.1"
              dns_nameservers = [
                "1.1.1.1",
                "1.0.0.1",
              ]
            }
          ]
        },
      ]
    }
    package_update  = false
    package_upgrade = false
    # packages        = concat(local.base_packages, var.additional_packages) # netcat is required for acting as an ssh jump jost
    runcmd = concat([
      local.security_setup,
      <<-EOT
      killall apt-get || true
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
      DEBIAN_FRONTEND=noninteractive apt-get install -y ${join(" ", concat(local.base_packages, var.additional_packages))}
      EOT
      ,
      <<-EOT
      ${local.k3s_install~}
      sh -s - server \
      --cluster-init \
      ${local.control_plane_arguments~}
      ${!var.control_plane_main_schedule_workloads ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""} \
      ${var.control_plane_k3s_additional_options} %{for key, value in local.kube-apiserver-args} --kube-apiserver-arg=${key}=${value} %{endfor~}
      EOT
      ,
      <<-EOT
      while ! test -d /var/lib/rancher/k3s/server/manifests; do
        echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
        sleep 1
      done
      EOT
      ,
      "kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/${var.calico_version}/manifests/tigera-operator.yaml",
      "kubectl apply -f /run/calico.yml",
      "kubectl -n kube-system create secret generic hcloud --from-literal=token=${var.hcloud_token} --from-literal=network=${hcloud_network.private.id}",
      <<-EOT
      if [ "${var.hcloud_ccm_driver_install}" = "true" ]; then
        wget -qO /var/lib/rancher/k3s/server/manifests/hcloud-ccm.yaml "https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/download/${var.hcloud_ccm_driver_version}/ccm-networks.yaml"
      fi
      EOT
      ,
      "kubectl -n kube-system create secret generic hcloud-csi --from-literal=token=${var.hcloud_token}",
      <<-EOT
      if [ "${var.hcloud_csi_driver_install}" = "true" ]; then
        wget -qO /run/csi/csi.yaml "https://raw.githubusercontent.com/hetznercloud/csi-driver/${var.hcloud_csi_driver_version}/deploy/kubernetes/hcloud-csi.yml"
        kubectl kustomize /run/csi >/var/lib/rancher/k3s/server/manifests/hcloud-csi.yaml
      fi
      EOT
    ], var.additional_runcmd)
    write_files = [
      {
        path    = "/run/csi/kustomization.yml"
        content = file("${path.module}/templates/kustomization.yml")
      },
      {
        path = "/run/calico.yml"
        content = templatefile("${path.module}/templates/calico.yml", {
          cluster_cidr_network = local.cluster_cidr_network
        })
      },
      {
        path    = "/etc/systemd/network/default-route.network"
        content = file("${path.module}/templates/default-route.network")
      },
    ]
    }),
    yamlencode(var.additional_cloud_init)
  )
}

resource "local_file" "control_plane_main_user_data" {
  count           = var.create_scripts ? 1 : 0
  filename        = "./control_plane_main_user_data"
  content         = local.control_plane_main_user_data
  file_permission = "0600"
}

# Placement group

# resource "hcloud_placement_group" "control_plane" {
#   name   = "${var.cluster_name}-control-plane"
#   type   = "spread"
#   labels = var.control_plane_main_labels
# }

# # Load balancer
#
# resource "hcloud_load_balancer" "control_plane_load_balancer" {
#   count              = var.enable_load_balancer ? 1 : 0
#   name               = "${var.cluster_name}-main-lb"
#   delete_protection  = var.delete_protection
#   load_balancer_type = "lb11"
#   location           = var.location
# }
#
# resource "hcloud_load_balancer_target" "load_balancer_target" {
#   depends_on       = [hcloud_load_balancer.control_plane_load_balancer[0], hcloud_server.control_plane_main]
#   count            = var.enable_load_balancer ? 1 : 0
#   type             = "server"
#   load_balancer_id = hcloud_load_balancer.control_plane_load_balancer[0].id
#   server_id        = hcloud_server.control_plane_main.id
#   use_private_ip   = true
# }
#
# resource "hcloud_load_balancer_network" "network" {
#   depends_on       = [hcloud_network.private]
#   count            = var.enable_load_balancer ? 1 : 0
#   load_balancer_id = hcloud_load_balancer.control_plane_load_balancer[0].id
#   network_id       = hcloud_network.private.id
# }
#
# resource "hcloud_load_balancer_service" "ssh" {
#   count            = var.enable_load_balancer ? 1 : 0
#   load_balancer_id = hcloud_load_balancer.control_plane_load_balancer[0].id
#   protocol         = "tcp"
#   listen_port      = 22222 # use non-standard SSH port to reduce attack vector
#   destination_port = 22
#   health_check {
#     protocol = "tcp"
#     port     = 22
#     interval = 10
#     timeout  = 5
#     retries  = 5
#   }
# }
#
# resource "hcloud_load_balancer_service" "kubernetes_api" {
#   count            = var.enable_load_balancer ? 1 : 0
#   load_balancer_id = hcloud_load_balancer.control_plane_load_balancer[0].id
#   protocol         = "tcp"
#   listen_port      = 6443
#   destination_port = 6443
#   health_check {
#     protocol = "tcp"
#     port     = 6443
#     interval = 10
#     timeout  = 5
#     retries  = 5
#   }
# }
