#!/bin/bash

# Create our policies
echo 'path "lob_a/workshop/*" {
    capabilities = ["read", "list", "create", "delete", "update"]
}' > lob_a_policy.hcl

echo 'path "secret/*" {
    capabilities = ["read", "list", "create"]
}' > secret.hcl

# Write the policies
vault policy write lob_a lob_a_policy.hcl
vault policy write secret secret.hcl