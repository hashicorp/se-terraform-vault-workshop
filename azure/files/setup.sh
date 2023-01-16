#!/bin/sh
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: Apache-2.0

# Configures the Vault server for workshops and demos

# cd /tmp
sudo apt-get -y update > /dev/null 2>&1
sudo apt install -y unzip jq cowsay mysql-client > /dev/null 2>&1
wget https://releases.hashicorp.com/vault/1.1.1/vault_1.1.1_linux_amd64.zip
sudo unzip vault_1.1.1_linux_amd64.zip -d /usr/local/bin/

# Set Vault up as a systemd service
echo "Installing systemd service for Vault..."
sudo bash -c "cat >/etc/systemd/system/vault.service" << 'EOF'
[Unit]
Description=Hashicorp Vault
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/usr/local/bin/vault server -dev -dev-root-token-id=root -dev-listen-address=0.0.0.0:8200
Restart=on-failure # or always, on-abort, etc

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start vault

echo "Setting up environment variables..."
echo "export VAULT_ADDR=http://localhost:8200" >> $HOME/.bashrc
echo "export VAULT_TOKEN=root" >> $HOME/.bashrc
echo "export MYSQL_HOST=${MYSQL_HOST}" >> $HOME/.bashrc
echo "Vault installation complete."
