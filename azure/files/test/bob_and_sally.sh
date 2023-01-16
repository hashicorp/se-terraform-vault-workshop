#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: Apache-2.0


# Enable userpass at mount workshop/userpass
vault auth enable -path=userpass userpass

# Create users 
vault write auth/userpass/users/bob \
    password=foo \
    policies=secret

vault write auth/userpass/users/sally \
    password=foo \
    policies=lob_a

echo "Script complete."