variable "docker_image_vault" {
  default = "hashicorp/vault-enterprise:1.13-ent"
}

variable "vault_license" {
  default = "~/Downloads/vault_nov2024.hclic"
}

variable "docker_image_openldap" {
  default = "osixia/openldap:1.4.0"
}