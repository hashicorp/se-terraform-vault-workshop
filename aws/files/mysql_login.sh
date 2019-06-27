#!/bin/bash
# Logs the user onto the MySQL server using dynamic Vault credentials

{ read USER; read PASS; } < <(curl --header 'X-Vault-Token: root' http://localhost:8200/v1/lob_a/workshop/database/creds/workshop-app-long | jq -r '.data | .username,.password')

mysql -h ${MYSQL_HOST} \
-u ${USER} -p${PASS} -e "show databases"

echo "Script complete."
