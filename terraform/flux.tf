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

data "github_repository" "this" {
  name        = var.github_repository
  description = var.github_repository
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = data.github_repository.this.name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

resource "null_resource" "sops_age_secret" {
  depends_on = [ null_resource.kubeconfig ]
  
  triggers = {
    flux_sops_age_secret_key = var.flux_sops_age_secret_key
  }

  provisioner "local-exec" {
    environment = {
      "FLUX_SOPS_AGE_SECRET_KEY" = var.flux_sops_age_secret_key
    }
    command = "echo $FLUX_SOPS_AGE_SECRET_KEY | kubectl create secret generic sops-age --namespace=flux-system --from-file=age.agekey=/dev/stdin --dry-run -o yaml | kubectl apply -f -"
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on = [ null_resource.sops_age_secret ]
  embedded_manifests = true
  path               = "bootstrap"
}
