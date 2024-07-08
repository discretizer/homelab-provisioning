provider "sops" {
}

# kustomize cilium manifests
resource "local_file" "cilium_kustomization" {
  filename = "${path.module}/manifests/cilium/base/kustomization.yaml"
  content  = templatefile("${path.module}/manifests/cilium/base/kustomization.yaml.tpl", {
    cilium_version = var.talos_data.cilium_version
  })
}

resource "null_resource" "cilium_manifest" {
  triggers = {
    cilium_version = var.talos_data.cilium_version
    cilium_base_kustomization = local_file.cilium_kustomization.content_md5
    cilium_base_values = filemd5("${path.module}/manifests/cilium/base/values.yaml")
    cilium_scheduling = filemd5("${path.module}/manifests/cilium/high-priority-scheduling.yaml")
    cilium_kustomization = filemd5("${path.module}/manifests/cilium/kustomization.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl kustomize --enable-helm ${path.module}/manifests/cilium | sops -e --input-type yaml --output-type yaml /dev/stdin > ${path.module}/manifests/cilium-manifests.yaml"
  }
}

data "sops_file" "cilium_manifest_encrypted" {
  depends_on = [ null_resource.cilium_manifest ]
  source_file = "${path.module}/manifests/cilium-manifests.yaml"
}


resource "talos_machine_configuration_apply" "cilium_apply" {
  for_each = var.node_data.controlplanes

  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = talos_machine_configuration_apply.control_plane[each.key].machine_configuration

  node = each.key
  config_patches = sensitive([
    templatefile("${path.module}/talos-patches/inline-manifests.yaml.tftpl", {
      name = "cilium"
      manifests = data.sops_file.cilium_manifest_encrypted.raw
    })
  ])
}
