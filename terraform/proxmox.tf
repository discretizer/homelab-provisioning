data "proxmox_virtual_environment_nodes" "available_nodes" {}

locals {
  proxmox_nodes = data.proxmox_virtual_environment_nodes.available_nodes.names
  proxmox_vms = merge({ for k, v in var.node_data.controlplanes : k=>merge(v, {
      description = "Control Plane Node", 
      tags = ["k8s", "controlplane", "development"], 
      image_file_id = resource.proxmox_virtual_environment_download_file.talos_controlplane_image_download["${v.vm_host}-controlplane"].id
    })}, 
    { for k, v in var.node_data.workers : k=>merge(v,{
      description = "Worker Node", 
      tags = ["k8s", "worker", "development"], 
      image_file_id = resource.proxmox_virtual_environment_download_file.talos_worker_image_download["${v.vm_host}-worker"].id
    })
  })
}

resource "proxmox_virtual_environment_download_file" "talos_worker_image_download" {
  for_each = toset( formatlist("%s-worker", local.proxmox_nodes)) 

  provider     = proxmox
  node_name    = split("-", each.key)[0]
  content_type = "iso"
  datastore_id = "local"
  file_name    = "talos-worker-v${var.talos_data.talos_version}-amd64${local.secure_boot}.iso"

  url = "https://factory.talos.dev/image/${local.talos_worker_schematic_id}/v${var.talos_data.talos_version}/metal-amd64${local.secure_boot}.iso"
}

resource "proxmox_virtual_environment_download_file" "talos_controlplane_image_download" {
  for_each = toset( formatlist("%s-controlplane", local.proxmox_nodes)) 

  provider     = proxmox
  node_name    = split("-", each.key)[0]
  content_type = "iso"
  datastore_id = "local"
  file_name    = "talos-controlplane-v${var.talos_data.talos_version}-amd64${local.secure_boot}.iso"

  url = "https://factory.talos.dev/image/${local.talos_controlplane_schematic_id}/v${var.talos_data.talos_version}/metal-amd64${local.secure_boot}.iso"
}


resource "proxmox_virtual_environment_vm" "vms" {
  for_each = local.proxmox_vms
  
  provider  = proxmox
  node_name = each.value.vm_host

  name        = each.value.hostname
  description = each.value.description
  tags        = each.value.tags
  on_boot     = true

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  vga {
    type   = "std"
  }

  memory {
    dedicated = each.value.memory
  }

  cdrom {
    enabled = true
    file_id = each.value.image_file_id
  }

  network_device {
    model      = "virtio"
    bridge      = "vmbr0"
    firewall    = false
    mac_address = var.node_mac_addresses[each.key]
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  tpm_state {
    datastore_id = "local-lvm"
    version      = "v2.0"
  }

  disk {
    file_format  = "raw"
    datastore_id = "local-lvm"
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    size         = each.value.disk_size
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  lifecycle {
    ignore_changes = [
      disk,
      hostpci, 
      kvm_arguments, 
      cpu, 
      memory
    ]
  }
}