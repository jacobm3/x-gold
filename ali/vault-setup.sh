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


# On the web server, run:
curl 'http://100.100.100.200/latest/meta-data/ram/security-credentials/web-instance-role'
 {
  "AccessKeyId" : "STS.NUvuKYpeAcTxxxxxxxdGxHnz",
  "AccessKeySecret" : "ACGQ7u1syAHjxxxxxxxxxxxxxxxxxxxxxxxxxxxKrKQvoJA",
  "Expiration" : "2020-04-23T09:22:05Z",
  "SecurityToken" : "CAISjQJ1q6Ft5B2yfSjIrxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxgEzBMopYhLomADd/iRfbxJ92PCTmd5AIRrJL+cTK9JS/HVbSClZ9gaPkOQwC8dkAoLdxKJwxk2qR4XDmrQpTLCBPxhXfKB0dFoxd1jXgFiZ6y2cqB8BHT/jaYo60339mvf8f9P5QzYs0lDInkg7xMG/CfgH4A2X9j77xriaFIwzDDs+yGDkNZixf8avMD6VHJ6dOFjgUY1fiIFSC+YVNN2AzD7RVWJYz7Cuy9Ij/PPY7tJARuTvaJm5Cw9fuifLxEtPfJvzxRvtDc8OopNuqCBGVXikYRup9yI1iyZbct1fxDZIZZRSMTG3nezzvXOCxLtzmLnPkV07UHZoLXmpsqppP1KW",
  "LastUpdated" : "2020-04-23T03:22:05Z",
  "Code" : "Success"
}

Use these fields in the following command from the web server:

vault login -method=alicloud \
  access_key=STS.xxxxxxxxxxxxxxxxxxxxxx \
  secret_key=ACGQ7u1xxxxxxxxxxxxxxxxxxxxxxxppjKrKQvoJA \
  security_token=CAISjQJ1q6Ft5B2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx+aWloLs1x9LNuwQSSPbSZASCB4JqFYcXBqAAX5zAzRXqIhvMD6VHJ6dOFjgUY1fiIFSC+YVNN2AzD7RVWJYz7Cuy9Ij/PPY7tJARuTvaJm5Cw9fuifLxEtPfJvzxRvtDc8OopNuqCBGVXikYRup9yI1iyZbct1fxDZIZZRSMTG3nezzvXOCxLtzmLnPkV07UHZoLXmpsqppP1KW \
  region=cn-qingdao

That will generate a Vault token scoped to the matching Vault role:

Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                         Value
---                         -----
token                       s.fuxxxxxxxxxxxxxxxxxxxxxKQ.tv22s
token_accessor              6MVMtggguuEac3JMovfvMs3Z.tv22s
token_duration              768h
token_renewable             true
token_policies              ["default"]
identity_policies           []
policies                    ["default"]
token_meta_arn              acs:ram::5657185762276978:assumed-role/web-instance-role/vm-ram-i-m5e8z2q1jg4gnsdfkomb
token_meta_identity_type    AssumedRoleUser
token_meta_principal_id     345377512072480607:vm-ram-i-m5e8z2q1jg4gnsdfkomb
token_meta_request_id       A3D1B64A-F30D-41F8-A03E-5448CA35B160
token_meta_role_id          345377512072480607
token_meta_role_name        web-instance-role
token_meta_user_id          n/a
token_meta_account_id       5657185762276978
