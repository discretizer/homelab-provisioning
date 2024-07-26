
resource "talos_machine_secrets" "secrets" {}

data "http" "talos_worker_schematic_id" {
  url = "https://factory.talos.dev/schematics"
  method = "POST"

  request_body= jsonencode({
    "customization": {
      "systemExtensions": {
        "officialExtensions": [
          "siderolabs/iscsi-tools",
          "siderolabs/nvidia-container-toolkit",
          "siderolabs/nonfree-kmod-nvidia",
          "siderolabs/qemu-guest-agent"
        ]
      }
    }
  })
}

data "http" "talos_controlplane_schematic_id" {
  url = "https://factory.talos.dev/schematics"
  method = "POST"

  request_body= jsonencode({
    "customization": {
      "systemExtensions": {
        "officialExtensions": [
          "siderolabs/qemu-guest-agent"
        ]
      }
    }
  })
}

locals  {
  talos_controlplane_schematic_id=jsondecode(data.http.talos_controlplane_schematic_id.response_body).id
  talos_worker_schematic_id=jsondecode(data.http.talos_worker_schematic_id.response_body).id

  secure_boot = var.talos_data.secure_boot ? "-secureboot" : ""

  talos_default_options = {
    topology_region     = var.cluster_name
    network_gateway     = var.network_gateway
  }
  talos_controlplane_options = merge( local.talos_default_options, {
    install_image_url   =  "factory.talos.dev/installer${local.secure_boot}/${local.talos_controlplane_schematic_id}:v${var.talos_data.talos_version}"
  })
  talos_worker_options = merge( local.talos_default_options, {
    install_image_url   =  "factory.talos.dev/installer${local.secure_boot}/${local.talos_worker_schematic_id}:v${var.talos_data.talos_version}"
  })

  cluster_endpoint = var.cluster_endpoint != "" ? var.cluster_endpoint : "https://${var.cluster_vip}:${var.cluster_endpoint_port}"
  first_control_plane = keys(var.node_data.controlplanes)[0]
}

# This block creates a generic control plane node configuration,
# from an existing template, populating it with sane default values
# that are appropriate for any node (control plane or worker)
data "talos_machine_configuration" "control_plane" {
  machine_type     = "controlplane"

  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  cluster_name       = var.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  talos_version      = "v${var.talos_data.talos_version}"
  kubernetes_version = "v${var.talos_data.k8s_version}"
  docs               = false
  examples           = false

  config_patches = [
    templatefile("${path.module}/talos-patches/default.yaml.tpl", local.talos_controlplane_options),
  ]
}

# This block creates a generic worker node configuration,
# from an existing template, populating it with sane default values
# that are appropriate for any node (control plane or worker)
data "talos_machine_configuration" "worker_node" {
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  cluster_name       = var.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  talos_version      = "v${var.talos_data.talos_version}"
  kubernetes_version = "v${var.talos_data.k8s_version}"
  docs               = false
  examples           = false

  config_patches = [
    templatefile("${path.module}/talos-patches/default.yaml.tpl", local.talos_worker_options),
    file("${path.module}/talos-patches/gpu-worker-patch.yaml"),
    file("${path.module}/talos-patches/mayastor-patch.yaml"),
    file("${path.module}/talos-patches/local-storage-patch.yaml"), 
    file("${path.module}/talos-patches/nvidia-default-runtimeclass.yaml"),
  ]
}


data "talos_client_configuration" "cc" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
  endpoints            = concat([var.cluster_vip], [for node in var.node_data.controlplanes : node.hostname])
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each = var.node_data.controlplanes
  depends_on = [ proxmox_virtual_environment_vm.vms ]

  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration

  node = each.key
  config_patches = [
    templatefile("${path.module}/talos-patches/control-plane.yaml.tftpl", {
      topology_zone     = each.value.vm_host,
      topology_region   = var.cluster_name,
      cluster_domain    = var.cluster_domain,
      cluster_endpoint  = local.cluster_endpoint,
      network_interface = "enx${lower(replace(var.node_mac_addresses[each.key], ":", ""))}",
      network_ip_prefix = var.network_ip_prefix,
      network_gateway   = var.network_gateway,
      hostname          = each.value.hostname,
      ipv4_local        = each.key,
      ipv4_vip          = var.cluster_vip,
    }),
  ]
}

resource "talos_machine_configuration_apply" "worker_node" {
  for_each = var.node_data.workers

  depends_on = [ proxmox_virtual_environment_vm.vms ]

  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker_node.machine_configuration

  node = each.key
  config_patches = concat([
    templatefile("${path.module}/talos-patches/worker-node.yaml.tpl", {
      topology_zone     = each.value.vm_host,
      topology_region   = var.cluster_name,
      cluster_domain    = var.cluster_domain,
      cluster_endpoint  = local.cluster_endpoint,
      network_interface = "enx${lower(replace(var.node_mac_addresses[each.key], ":", ""))}",
      network_ip_prefix = var.network_ip_prefix,
      network_gateway   = var.network_gateway,
      hostname          = each.value.hostname,
      ipv4_local        = each.key,
      ipv4_vip          = var.cluster_vip,
    }),
    templatefile("${path.module}/talos-patches/node-labels.yaml.tpl", {
      node_labels = jsonencode(each.value.node_labels),
    })
  ])
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.worker_node,
    talos_machine_configuration_apply.cilium_apply
  ]
  node                 = keys(var.node_data.controlplanes)[0]
  client_configuration = talos_machine_secrets.secrets.client_configuration
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_configuration_apply.control_plane
  ]
  client_configuration = talos_machine_secrets.secrets.client_configuration
  node                 = keys(var.node_data.controlplanes)[0]
}
