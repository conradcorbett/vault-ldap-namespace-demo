# vault-ldap-namespace-demo
Makefile is still under development, do you not use make to build the environment

## Apply the terraform code in vault-server:
```shell
cd vault-server && \
terraform init && \
terraform apply -auto-approve
Get the root vault token
export VAULT_TOKEN=$(docker logs $(docker ps -aqf "name=vault") 2>&1 | grep Token | awk '{print $3}')
ldapadd -cxD "cn=admin,dc=hashidemos,dc=com" -f learn-vault-example.ldif -w 1LearnVault
```

## Apply the terraform code in vault-setup:
```shell
cd ../vault-setup && terraform apply -auto-approve
```

## Test authenticating and policies
### Login as solutions_engineering group member, you have permission to list and create namespaces in the root namespace only.
```shell
unset VAULT_TOKEN
vault login -method=ldap -path=ldap/ username=jlundberg password=thispasswordsucks 
vault namespace list
VAULT_NAMESPACE=ns1 vault namespace list
```

### Login as vault admin group member, you have super user permissions. You can create child namespaces.
```shell
unset VAULT_TOKEN
vault login -method=ldap -path=ldap/ username=vaultadmin1 password=thispasswordsucks
VAULT_NAMESPACE=ns1 vault namespace list
VAULT_NAMESPACE=ns1 vault namespace create namespaceA
```
### Login as ns1 admin group member, you have permissions for ns1 only.
```shell
unset VAULT_TOKEN
vault login -method=ldap -path=ldap/ username=ns1_admin_1 password=thispasswordsucks
vault namespace list
VAULT_NAMESPACE="ns1" vault namespace list
```