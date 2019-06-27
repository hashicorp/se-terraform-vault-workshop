#!/bin/sh

# Note: This script requires that the VAULT_ADDR, VAULT_TOKEN, and MYSQL_HOST environment variables be set.
# Example:
# export VAULT_ADDR=http://127.0.0.1:8200
# export VAULT_TOKEN=root
# export MYSQL_HOST=bugsbunny-mysql-server

echo "Enabling the vault transit secrets engine..."

# Enable the transit secret engine
vault secrets enable -path=lob_a/workshop/transit transit

# Create our customer key
vault write -f lob_a/workshop/transit/keys/customer-key

# Create our archive key to demonstrate multiple keys
vault write -f lob_a/workshop/transit/keys/archive-key

echo "Installing application prerequisites..."

# Install app prerequisites
sudo apt-get -y update > /dev/null 2>&1
sudo apt-get install -y python3-pip > /dev/null 2>&1
sudo -H pip3 install mysql-connector-python hvac flask > /dev/null 2>&1

echo "Downloading and installing the application..."

git clone https://github.com/norhe/transit-app-example.git

cat << EOF > ~/transit-app-example/backend/config.ini
[DEFAULT]
LogLevel = WARN

[DATABASE]
Address=${MYSQL_HOST}
Port=${MYSQL_PORT}
User=hashicorp@${MYSQL_HOST}
Password=Password123!
Database=my_app

[VAULT]
Enabled = False
DynamicDBCreds = False
ProtectRecords=False
Address=http://localhost:8200
#Address=vault.service.consul
Token=root
KeyPath=lob_a/workshop/transit
KeyName=customer-key
EOF

echo "Script complete."
