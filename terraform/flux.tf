provider "flux" {
    kubernetes = {
        host = data.talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.host

        client_certificate     = base64decode(data.talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_certificate)
        client_key             = base64decode(data.talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_key)
        cluster_ca_certificate = base64decode(data.talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.ca_certificate)
    }
    git = {
        url = "ssh://git@github.com/${var.github_owner}/${var.github_repository}.git"
        ssh = {
            username    = "git"
        private_key = tls_private_key.flux.private_key_pem
        }
    }
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}


resource "github_repository" "this" {
  name        = var.github_repository
  description = var.github_repository
  visibility  = "private"
  auto_init   = true # This is extremely important as flux_bootstrap_git will not work without a repository that has been initialised
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = github_repository.this.name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository.this]

  embedded_manifests = true
  path               = "clusters/geohomelab"
}
