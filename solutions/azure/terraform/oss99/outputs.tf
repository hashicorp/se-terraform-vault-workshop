##############################################################################
# Outputs File
#
# Expose the outputs you want your users to see after a successful 
# `terraform apply` or `terraform output` command. You can add your own text 
# and include any data from the state file. Outputs are sorted alphabetically;
# use an underscore _ to move things to the bottom. In this example we're 
# providing instructions to the user on how to connect to their own custom 
# demo environment.
#
# output "Vault_Server_URL" {
#   value = "http://${azurerm_public_ip.vault-pip.fqdn}:8200"
# }
# output "MySQL_Server_FQDN" {
#   value = "${azurerm_mysql_server.mysql.fqdn}"
# }
# output "Instructions" {
#   value = <<EOF
#
# # Connect to your Linux Virtual Machine
# #
# # Run the command below to SSH into your server. You can also use PuTTY or any
# # other SSH client. Your password is: ${var.admin_password}
# 
# ssh ${var.admin_username}@${azurerm_public_ip.vault-pip.fqdn}
# EOF
# }

