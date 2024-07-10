variable "github_repository" {
  description = "The name of the github repository"
  type        = string
}

variable "github_token" {
  description = "The github token"
  type        = string
}

variable "github_owner" {
  description = "The github owner"
  type        = string
}

variable "flux_sops_age_secret_key" {
  description = "The key for the sops age secret"
  type        = string
  sensitive = true
}