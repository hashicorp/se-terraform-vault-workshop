#!/bin/sh

# Note: This script requires that the VAULT_ADDR, VAULT_TOKEN, and MYSQL_HOST environment variables be set.
# Example:
# export VAULT_ADDR=http://127.0.0.1:8200
# export VAULT_TOKEN=root
# export MYSQL_HOST=bugsbunny-mysql-server

# Enable the transit secret engine
vault secrets enable -path=lob_a/workshop/transit transit

# Create our customer key
vault write -f lob_a/workshop/transit/keys/customer-key

# Create our archive key to demonstrate multiple keys
vault write -f lob_a/workshop/transit/keys/archive-key

# Install app prerequisites
sudo apt-get -y update > /dev/null 2>&1
sudo apt-get install -y python3-pip > /dev/null 2>&1
sudo -H pip3 install mysql-connector-python hvac flask > /dev/null 2>&1

git clone https://github.com/norhe/transit-app-example.git

echo "Script complete."
