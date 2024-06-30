provider "kustomization" {
  kubeconfig_raw = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
}

# kustomize cilium manifests
resource "local_file" "cilium_kustomization" {
  filename = "${path.module}/manifests/cilium/base/kustomization.yaml"
  content  = templatefile("${path.module}/manifests/cilium/base/kustomization.yaml.tpl", {
    cilium_version = var.talos_data.cilium_version
  })
}

data "external" "get_helm_path" {
  program    = ["/bin/sh","${path.module}/find_helm.sh"]
}

data "kustomization_build" "cilium" {
    depends_on = [local_file.cilium_kustomization]
    path = "${path.module}/manifests/cilium"

    kustomize_options {
        load_restrictor = "none"
        enable_helm = true
        helm_path = "helm"
    }
}

resource "talos_machine_configuration_apply" "cilium_apply" {  
  for_each = var.node_data.controlplanes

  client_configuration        = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = talos_machine_configuration_apply.control_plane[each.key].machine_configuration
  
  node = each.key
  config_patches = sensitive([
    templatefile("${path.module}/talos-patches/inline-manifests.yaml.tftpl", {
      name = "cilium"
      manifests = flatten([ 
          [ for id in data.kustomization_build.cilium.ids_prio[0]: data.kustomization_build.cilium.manifests[id]], 
          [ for id in data.kustomization_build.cilium.ids_prio[1]: data.kustomization_build.cilium.manifests[id]],
          [ for id in data.kustomization_build.cilium.ids_prio[2]: data.kustomization_build.cilium.manifests[id]]
      ])
    })
  ])
}
