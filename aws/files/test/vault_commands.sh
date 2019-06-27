
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

# Enable userpass at mount workshop/userpass
vault auth enable -path=userpass userpass

# Create users 
vault write auth/userpass/users/bob \
    password=foo \
    policies=secret

vault write auth/userpass/users/sally \
    password=foo \
    policies=lob_a

# Enable database secrets engine
vault secrets enable -path=lob_a/workshop/database database

# Configure our secret engine
vault write lob_a/workshop/database/config/wsmysqldatabase \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(${MYSQL_HOST}.mysql.database.azure.com:3306)/" \
    allowed_roles="workshop-app","workshop-app-long" \
    username="hashicorp@${MYSQL_HOST}" \
    password="Password123!"

# Create our roles
vault write lob_a/workshop/database/roles/workshop-app-long \
    db_name=wsmysqldatabase \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO '{{name}}'@'%' WITH GRANT OPTION;FLUSH PRIVILEGES;" \
    default_ttl="1h" \
    max_ttl="24h"

vault write lob_a/workshop/database/roles/workshop-app \
    db_name=wsmysqldatabase \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO '{{name}}'@'%' WITH GRANT OPTION;FLUSH PRIVILEGES;" \
    default_ttl="5m" \
    max_ttl="1h"

# Enable the transit secret engine
vault secrets enable -path=lob_a/workshop/transit transit

# Create our customer key
vault write -f lob_a/workshop/transit/keys/customer-key

# Create our archive key to demonstrate multiple keys
vault write -f lob_a/workshop/transit/keys/archive-key

# Install app prerequisites
sudo apt-get -y update > /dev/null 2>&1
sudo apt-get install -y python3-pip > /dev/null 2>&1
sudo pip3 install mysql-connector-python hvac Flask > /dev/null 2>&1

# Retrieve test credentials
vault read lob_a/workshop/database/creds/workshop-app-long