provider "vault" {
  address = "http://127.0.0.1:8200"
}

#resource "vault_namespace" "solutions_engineering" {
#  path = "solutions_engineering"
#}

resource "vault_namespace" "ns1" {
  path = "ns1"
}

resource "vault_namespace" "ns2" {
  path = "ns2"
}

resource "vault_policy" "solutions_engineering" {
  depends_on = [vault_namespace.solutions_engineering]
  name       = "solutions_engineering"
# This policy allows the people in solutions engineering group to manage namespaces in root because this policy is created in root
  policy     = <<EOT
# Manage namespaces
path "sys/namespaces/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/acl/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies
path "sys/policies/acl" {
   capabilities = ["list"]
}

# Enable and manage secrets engines
path "sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secrets engines
path "sys/mounts" {
  capabilities = [ "read" ]
}

# Create and manage entities and groups
path "identity/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage tokens
path "auth/token/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets at 'edu-secret'
path "edu-secret/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_policy" "vault_admin" {
  name   = "vault_admin"
  policy = <<EOT
# Manage everything
path "*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}

resource "vault_policy" "ns1" {
  depends_on = [vault_namespace.ns1]

  name      = "ns1"
  namespace = "ns1"
  policy    = <<EOT
# Manage namespaces
path "sys/namespaces/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/acl/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies
path "sys/policies/acl" {
   capabilities = ["list"]
}

# Enable and manage secrets engines
path "sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secrets engines
path "sys/mounts" {
  capabilities = [ "read" ]
}

# Create and manage entities and groups
path "identity/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage tokens
path "auth/token/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets at 'edu-secret'
path "edu-secret/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_policy" "ns2" {
  depends_on = [vault_namespace.ns2]

  name      = "ns2"
  namespace = "ns2"
  policy    = <<EOT
# Manage namespaces
path "sys/namespaces/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/acl/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies
path "sys/policies/acl" {
   capabilities = ["list"]
}

# Enable and manage secrets engines
path "sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secrets engines
path "sys/mounts" {
  capabilities = [ "read" ]
}

# Create and manage entities and groups
path "identity/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage tokens
path "auth/token/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets at 'edu-secret'
path "edu-secret/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_ldap_auth_backend" "ldap" {
  url          = "ldap://host.docker.internal:389"
  binddn       = "cn=read-only,dc=hashidemos,dc=com"
  bindpass     = "devsecopsFTW"
  userdn       = "ou=people,dc=hashidemos,dc=com"
  userattr     = "cn"
  groupdn      = "ou=um_group,dc=hashidemos,dc=com"
  groupfilter  = "(&(objectClass=groupOfUniqueNames)(uniqueMember={{.UserDN}}))"
  groupattr    = "cn"
  insecure_tls = true

}

resource "vault_ldap_auth_backend_group" "vault_admins" {
  groupname = "vault_admins"
  policies  = [vault_policy.vault_admin.name]
  backend   = vault_ldap_auth_backend.ldap.path
}

resource "vault_identity_group" "solutions_engineering_root" {
  name = "solutions_engineering_root"
  type = "external"
  policies         = [vault_policy.solutions_engineering.name]
}

resource "vault_identity_group_alias" "solutions_engineering" {
  name           = "solutions_engineering"
  mount_accessor = vault_ldap_auth_backend.ldap.accessor
  canonical_id   = vault_identity_group.solutions_engineering_root.id
}

resource "vault_identity_group" "ns1_admins_root" {
  name = "ns1_admins_root"
  type = "external"
}

resource "vault_identity_group_alias" "ns1_admins" {
  name           = "ns1_admins"
  mount_accessor = vault_ldap_auth_backend.ldap.accessor
  canonical_id   = vault_identity_group.ns1_admins_root.id
}

resource "vault_identity_group" "ns1" {
  namespace        = "ns1"
  name             = "ns1"
  type             = "internal"
  policies         = [vault_policy.ns1.name]
  member_group_ids = [vault_identity_group_alias.ns1_admins.canonical_id]
}

resource "vault_identity_group" "ns2_admins_root" {
  name = "ns2_admins_root"
  type = "external"
}

resource "vault_identity_group_alias" "ns2_admins" {
  name           = "ns2_admins"
  mount_accessor = vault_ldap_auth_backend.ldap.accessor
  canonical_id   = vault_identity_group.ns2_admins_root.id
}

resource "vault_identity_group" "ns2" {
  namespace        = "ns2"
  name             = "ns2"
  type             = "internal"
  policies         = [vault_policy.ns2.name]
  member_group_ids = [vault_identity_group_alias.ns2_admins.canonical_id]
}
