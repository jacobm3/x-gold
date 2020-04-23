ns=ali-web
vault namespace create $ns

export VAULT_NAMESPACE=$ns
vault auth enable alicloud

# Create a RAM role
# RAM -> RAM Roles -> Create RAM Role -> Ali svc -> ECS
# Create one a RAM ECS instance role granting Vault permission to create tokens (Ali secrets engine)
# Create another RAM ECS instance role for the client so it can authenticate to Vault using
# its local instance metadata

# client metadata role
vault write auth/alicloud/role/web-instance-role arn='acs:ram::5657185762276978:role/web-instance-role'





