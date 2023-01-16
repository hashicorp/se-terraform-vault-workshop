#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: Apache-2.0


# Create a read only policy for Sally
echo 'path "secret/*" {
    capabilities = ["read", "list"]
}' > readonly.hcl

vault policy write readonly readonly.hcl

# Recreate Sally's account with new policy
vault write auth/userpass/users/sally \
    password=foo \
    policies=lob_a,readonly

echo "Script complete."