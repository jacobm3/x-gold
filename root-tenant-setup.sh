This test is designed to show Vault can implement the "Gold Standard" for separation
of duties, where no single Vault admin can access the secrets stored by other users,
applications or teams.

It involves 3 personas:

- Vault admins (3 of 5 initial unseal key and root token holders)
- Project-01 admin (creates secrets)
- Project-02 admin (tries to access Project-01 secrets)

Process:

# Login with root token

# Create top level namespace names
ns1="us"
ns1a="upstream"
ns1b="chemical"

vault namespace create $ns1
vault namespace create -namespace $ns1 $ns1a
vault namespace create -namespace $ns1 $ns1b

# Create: 
#   - batch of namespaces under us/upstream
#   - space-admin policy in each namespace
#   - response-wrapped token with space-admin policy attached

script namespace-token-log.txt
count=10
set -x
for x in `seq -w 1 10`; do
  vault namespace create -namespace=$ns1/$ns1a proj-$x
  echo
  vault policy write -namespace=$ns1/$ns1a/proj-$x space-admin - <<EOF
path "*" {
capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF
  echo "Admin token for namespace $ns1/$ns1a/proj-$x:"
  vault token create -policy=space-admin -wrap-ttl=8760h -namespace=$ns1/$ns1a/proj-$x 
done
set +x
exit


# Response wrapping references:
# https://www.vaultproject.io/docs/concepts/response-wrapping
# https://learn.hashicorp.com/vault/secrets-management/sm-cubbyhole


# That loop will produce a log (namespace-token-log.txt) with output like this, 
# for each namespace:
#
# Key     Value
# ---     -----
# id      5s6lC
# path    us/upstream/proj-01/
# Success! Uploaded policy: space-admin
#
# Admin token for namespace us/upstream/proj-01:
# Key                              Value
# ---                              -----
# wrapping_token:                  s.mCt7OmqE1bUKHxBweGc2Bkoy.5s6lC
# wrapping_accessor:               X6bop97eBKiS6fQhnwP6oUnw.5s6lC
# wrapping_token_ttl:              8760h
# wrapping_token_creation_time:    2020-04-21 00:17:08.4478966 -0500 CDT
# wrapping_token_creation_path:    auth/token/create
# wrapped_accessor:                JdegSfcmBGpu4pv9GAIbhtco.5s6lC

# These values are saved and delivered to project admins as needed. 

# Revoke the root token, so no individual other than project owners can 
# access their secrets.

$ vault login  # <-- root token
Token (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.pEZRMCQ0xma9hKxIbbDbZ2OJ
token_accessor       h6pmdXc0wj5gxK2qJFKTjo4b
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

$ vault token revoke -self -mode=orphan
Success! Revoked token (if it existed)
$ vault secrets list
Error listing secrets engines: Error making API request.

URL: GET http://127.0.0.1:8200/v1/sys/mounts
Code: 403. Errors:

* permission denied


# Deliver the 'wrapping_token' to the intended owner of the new namespace. 

# proj-01 owner receives namespace path (us/upstream/proj-01) and 
# unwraps their wrapping_token (s.mCt7OmqE1bUKHxBweGc2Bkoy.5s6lC)

$ VAULT_TOKEN=s.mCt7OmqE1bUKHxBweGc2Bkoy.5s6lC vault unwrap
Key                  Value
---                  -----
token                s.QhFhZMSI0mPMoop0BsEoafl6.5s6lC
token_accessor       JdegSfcmBGpu4pv9GAIbhtco.5s6lC
token_duration       768h
token_renewable      true
token_policies       ["default" "space-admin"]
identity_policies    []
policies             ["default" "space-admin"]

# proj-01 owner stores their unwrapped token (s.QhFhZMSI0mPMoop0BsEoafl6.5s6lC) and 
# uses it to configure any needed auth methods, policies and secrets engines inside their 
# project's namespace.

vault login  <-- proj-01 token

# use kv v2
$ export VAULT_NAMESPACE=us/upstream/proj-01
vault secrets enable kv-v2 
vault kv put kv-v2/my-secret my-value=some-random-value
vault kv get kv-v2/my-secret


# Unwrap proj-02 token, login and attempt to access proj-01 secret.

# Attempt to access proj-01 with the original root token.

# If root policy privileges are required for additional administration,
# regenerate root token with quorum of unseal key holders: 
# https://learn.hashicorp.com/vault/operations/ops-generate-root

