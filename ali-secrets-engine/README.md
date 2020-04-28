# Alicloud Secrets Engine

The AliCloud secrets engine dynamically generates AliCloud access tokens based on RAM policies, or AliCloud STS credentials based on RAM roles. 

## Setup

Execute this configuration with a Vault root token:

```

export VAULT_NAMESPACE=ali-web

vault secrets enable alicloud

vault write alicloud/config \
  access_key=${ALI_ACCESS_KEY} \
  secret_key=${ALI_SECRET_KEY}

vault write alicloud/role/policy-based \
    remote_policies='name:AliyunOSSReadOnlyAccess,type:System' \
    remote_policies='name:AliyunRDSReadOnlyAccess,type:System'

```

## Usage

Obtain a Vault token with access to `alicloud/creds/policy-based` and access this Vault endpoint with an appropriately scoped Vault token:

```
export VAULT_TOKEN=`cat ~vault-agent/.vault-token`

vault read alicloud/creds/policy-based

Key                Value
---                -----
lease_id           alicloud/creds/policy-based/j43CLFj3xxxxxxxxxxxxvoiUBxx.tv22s
lease_duration     768h
lease_renewable    true
access_key         LTAI4xxxxxxxxxxxxxxxxoKmt
secret_key         2L1xxxxxxxxxxxxxxxxxxxxxxxxVTvk


```

