# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: Apache-2.0

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
#   value = "http://${aws_instance.vault-server.public_ip}:8200"
# }
# output "MySQL_Server_FQDN" {
#   value = "${aws_db_instance.vault-demo.address}"
# }
# output "Instructions" {
#   value = <<EOF
#
# # Connect to your Linux Virtual Machine
# #
# # Run the command below to SSH into your server. You can also use PuTTY or any
# # other SSH client. Your SSH key is already loaded for you.
#
# ssh ubuntu@${aws_instance.vault-server.public_ip}
# EOF
# }
