# Terraform configuration for running Vault Enterprise in a Docker container
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

# Configure the Docker provider
provider "docker" {}

# Define the Docker container resource
resource "docker_container" "vault" {
  image = var.docker_image_vault
  name  = "vault_demo_ns"
  rm    = true

  env = [
    "VAULT_LICENSE=${file(var.vault_license)}"
  ]

  ports {
    internal = 8200
    external = 8200
  }
}

resource "docker_container" "openldap" {
  image = var.docker_image_openldap
  name  = "openldap"
  rm    = true

  env = [
    "LDAP_ORGANISATION=hashidemos",
    "LDAP_DOMAIN=hashidemos.com",
    "LDAP_ADMIN_PASSWORD=1LearnVault",
    "LDAP_READONLY_USER=true",
    "LDAP_READONLY_USER_USERNAME=read-only",
    "LDAP_READONLY_USER_PASSWORD=devsecopsFTW"
  ]

  ports {
    internal = 389
    external = 389
  }
  ports {
    internal = 636
    external = 636
  }
}