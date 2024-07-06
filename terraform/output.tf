output "talosconfig" {
  value     = data.talos_client_configuration.cc.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

output "controllers" {
  value = join(",", keys(var.node_data.controlplanes))
}

output "workers" {
  value = join(",", keys(var.node_data.workers))
}
