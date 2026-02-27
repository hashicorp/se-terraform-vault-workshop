output "Vault_Server_URL" {
  value = "http://${aws_instance.vault-server.public_ip}:8200"
}
output "MySQL_Server_FQDN" {
  value = "${aws_db_instance.vault-demo.address}"
}
output "Instructions" {
  value = <<EOF

# Connect to your Linux Virtual Machine
#
# Run the command below to SSH into your server. You can also use PuTTY or any
# other SSH client. Your SSH key is already loaded for you.

ssh ubuntu@${aws_instance.vault-server.public_ip}
EOF
}
