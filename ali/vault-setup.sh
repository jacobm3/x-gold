ns=ali-web
vault namespace create $ns

export VAULT_NAMESPACE=$ns
vault auth enable alicloud

# Create a RAM role
# RAM -> RAM Roles -> Create RAM Role
vault write auth/alicloud/role/web-role arn='acs:ram::5657185762276978:role/web-admin-role'




