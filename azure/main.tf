##############################################################################
# HashiCorp Terraform and Vault Workshop
# 
# This Terraform configuration will create the following:
#
# Azure Resource group with a virtual network and subnet
# A Linux server running HashiCorp Vault and a simple application
# A hosted Azure MySQL database server

/* First we'll create a resource group. In Azure every resource belongs to a 
resource group. Think of it as a container to hold all your resources. 
You can find a complete list of Azure resources supported by Terraform here:
https://www.terraform.io/docs/providers/azurerm/. Note the use of variables 
to dynamically set our name and location. Variables are usually defined in 
the variables.tf file, and you can override the defaults in your 
own terraform.tfvars file. */

resource "azurerm_resource_group" "vaultworkshop" {
  name     = "${var.prefix}-vault-workshop"
  location = "${var.location}"
}

/* The next resource is a Virtual Network. We can dynamically place it into the
resource group without knowing its name ahead of time. Terraform handles all
of that for you, so everything is named consistently every time. Say goodbye
to weirdly-named mystery resources in your Azure Portal. To see how all this
works visually, run `terraform graph` and copy the output into the online
GraphViz tool: http://www.webgraphviz.com/ */

# resource "azurerm_virtual_network" "vnet" {
#   name                = "${var.prefix}-vnet"
#   location            = "${azurerm_resource_group.vaultworkshop.location}"
#   address_space       = ["${var.address_space}"]
#   resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
# }

/* Next we'll build a subnet to run our VMs in. These variables can be defined 
via environment variables, a config file, or command line flags. Default 
values will be used if the user does not override them. You can find all the
default variables in the variables.tf file. You can customize this demo by
making a copy of the terraform.tfvars.example file. */

# resource "azurerm_subnet" "subnet" {
#   name                 = "${var.prefix}-subnet"
#   virtual_network_name = "${azurerm_virtual_network.vnet.name}"
#   resource_group_name  = "${azurerm_resource_group.vaultworkshop.name}"
#   address_prefix       = "${var.subnet_prefix}"
# }

/* Now that we have a network, we'll deploy a stand-alone HashiCorp Vault 
server. Vault supports a 'dev' mode which is appropriate for demonstrations
and development purposes. In other words, don't do this in production.
An Azure Virtual Machine has several components. In this example we'll build
a security group, a network interface, a public ip address, a storage 
account and finally the VM itself. Terraform handles all the dependencies 
automatically, and each resource is named with user-defined variables. */

# resource "azurerm_network_security_group" "vault-sg" {
#   name                = "${var.prefix}-sg"
#   location            = "${var.location}"
#   resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"

#   security_rule {
#     name                       = "Vault"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "8200"
#     source_address_prefix      = "${var.vault_source_ips}"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "Transit-App"
#     priority                   = 102
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "5000"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "SSH"
#     priority                   = 101
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "${var.ssh_source_ips}"
#     destination_address_prefix = "*"
#   }
# }

/* A network interface. This is required by the azurerm_virtual_machine 
resource. Terraform will let you know if you're missing a dependency. */

# resource "azurerm_network_interface" "vault-nic" {
#   name                      = "${var.prefix}-vault-nic"
#   location                  = "${var.location}"
#   resource_group_name       = "${azurerm_resource_group.vaultworkshop.name}"
#   network_security_group_id = "${azurerm_network_security_group.vault-sg.id}"

#   ip_configuration {
#     name                          = "${var.prefix}ipconfig"
#     subnet_id                     = "${azurerm_subnet.subnet.id}"
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = "${azurerm_public_ip.vault-pip.id}"
#   }
# }

/* Every Azure Virtual Machine comes with a private IP address. You can also 
optionally add a public IP address for Internet-facing applications and 
demo environments like this one. */

# resource "azurerm_public_ip" "vault-pip" {
#   name                = "${var.prefix}-ip"
#   location            = "${var.location}"
#   resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
#   allocation_method   = "Dynamic"
#   domain_name_label   = "${var.prefix}"
# }

/* And finally we build our Vault server. This is a standard Ubuntu instance.
We use the shell provisioner to run a Bash script that configures Vault for 
the demo environment. Terraform supports several different types of 
provisioners including Bash, Powershell and Chef. */

# resource "azurerm_virtual_machine" "vault" {
#   name                = "${var.prefix}-vault"
#   location            = "${var.location}"
#   resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
#   vm_size             = "${var.vm_size}"

#   network_interface_ids         = ["${azurerm_network_interface.vault-nic.id}"]
#   delete_os_disk_on_termination = "true"

#   storage_image_reference {
#     publisher = "${var.image_publisher}"
#     offer     = "${var.image_offer}"
#     sku       = "${var.image_sku}"
#     version   = "${var.image_version}"
#   }

#   storage_os_disk {
#     name              = "${var.prefix}-osdisk"
#     managed_disk_type = "Standard_LRS"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#   }

#   os_profile {
#     computer_name  = "${var.prefix}"
#     admin_username = "${var.admin_username}"
#     admin_password = "${var.admin_password}"
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   provisioner "file" {
#     source      = "files/setup.sh"
#     destination = "/home/${var.admin_username}/setup.sh"

#     connection {
#       type     = "ssh"
#       user     = "${var.admin_username}"
#       password = "${var.admin_password}"
#       host     = "${azurerm_public_ip.vault-pip.fqdn}"
#     }
#   }

#   provisioner "file" {
#     source      = "files/vault_setup.sh"
#     destination = "/home/${var.admin_username}/vault_setup.sh"

#     connection {
#       type     = "ssh"
#       user     = "${var.admin_username}"
#       password = "${var.admin_password}"
#       host     = "${azurerm_public_ip.vault-pip.fqdn}"
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /home/${var.admin_username}/*.sh",
#       "sleep 30",
#       "MYSQL_HOST=${var.prefix}-mysql-server /home/${var.admin_username}/setup.sh"
#     ]

#     connection {
#       type     = "ssh"
#       user     = "${var.admin_username}"
#       password = "${var.admin_password}"
#       host     = "${azurerm_public_ip.vault-pip.fqdn}"
#     }
#   }
# }

/* Azure MySQL Database
Vault will manage this database with the database secrets engine.
Terraform can build any type of infrastructure, not just virtual machines. 
Azure offers managed MySQL database servers and a whole host of other 
resources. Each resource is documented with all the available settings:
https://www.terraform.io/docs/providers/azurerm/r/mysql_server.html */

# resource "azurerm_mysql_server" "mysql" {
#   name                = "${var.prefix}-mysql-server"
#   location            = "${azurerm_resource_group.vaultworkshop.location}"
#   resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
#   ssl_enforcement     = "Disabled"

#   sku {
#     name     = "B_Gen5_2"
#     capacity = 2
#     tier     = "Basic"
#     family   = "Gen5"
#   }

#   storage_profile {
#     storage_mb            = 5120
#     backup_retention_days = 7
#     geo_redundant_backup  = "Disabled"
#   }

#   administrator_login          = "${var.admin_username}"
#   administrator_login_password = "${var.admin_password}"
#   version                      = "5.7"
#   ssl_enforcement              = "Disabled"
# }

/* This is a sample database that we'll populate with data from our app.
With Terraform, everything is Infrastructure as Code. No more manual steps,
aging runbooks, tribal knowledge or outdated wiki instructions. Terraform
is your executable documentation, and it will build infrastructure correctly
every time. */

# resource "azurerm_mysql_database" "wsmysqldatabase" {
#   name                = "wsmysqldatabase"
#   resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
#   server_name         = "${azurerm_mysql_server.mysql.name}"
#   charset             = "utf8"
#   collation           = "utf8_unicode_ci"
# }

/* Public IP addresses are not generated until they are attached to an object.
So we use a 'data source' here to fetch it once its available. Then we can
provide the public IP address to the next resource for allowing firewall 
access to our database. */

# data "azurerm_public_ip" "vault-pip" {
#   name                = "${azurerm_public_ip.vault-pip.name}"
#   depends_on          = ["azurerm_virtual_machine.vault"]
#   resource_group_name = "${azurerm_virtual_machine.vault.resource_group_name}"
# }

/* Allows the Linux VM to connect to the MySQL database, using the IP address
from the data source above. */

# resource "azurerm_mysql_firewall_rule" "vault-mysql" {
#   name                = "vault-mysql"
#   resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
#   server_name         = "${azurerm_mysql_server.mysql.name}"
#   start_ip_address    = "${data.azurerm_public_ip.vault-pip.ip_address}"
#   end_ip_address      = "${data.azurerm_public_ip.vault-pip.ip_address}"
# }
