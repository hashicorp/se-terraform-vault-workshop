##############################################################################
# HashiCorp Terraform and Vault Workshop
#
# This Terraform configuration will create the following:
#
# AWS VPC with a subnet
# A Linux server running HashiCorp Vault and a simple application
# A hosted RDS MySQL database server

/* This is the provider block. We recommend pinning the provider version to
a known working version. If you leave this out you'll get the latest
version. */

provider "aws" {
  version = "~> 2.0"
  region  = "${var.region}"
}

/* First we'll create a VPC. This will allow us to control the network for your applications.
You can find a complete list of AWS resources supported by Terraform here:
https://www.terraform.io/docs/providers/aws/index.html. Note the use of variables
to dynamically set our name and location. Variables are usually defined in
the variables.tf file, and you can override the defaults in your
own terraform.tfvars file. */

resource "aws_vpc" "workshop" {
  cidr_block       = "${var.address_space}"
  tags = {
    Name = "${var.prefix}-workshop"
  }
}

/* Next we'll build a subnet to run our VMs in. These variables can be defined
via environment variables, a config file, or command line flags. Default
values will be used if the user does not override them. You can find all the
default variables in the variables.tf file. You can customize this demo by
making a copy of the terraform.tfvars.example file. */

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.workshop.id}"
  cidr_block = "${var.subnet_prefix}"

  tags = {
    Name = "${var.prefix}-workshop-subnet"
  }
}


/* Other things required, such as internet gateways and routes */
resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.workshop.id}"

}

resource "aws_route_table" "main-public" {
    vpc_id = "${aws_vpc.workshop.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }
}

resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = "${aws_subnet.subnet.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}

/* Now that we have a network, we'll deploy a stand-alone HashiCorp Vault
server. Vault supports a 'dev' mode which is appropriate for demonstrations
and development purposes. In other words, don't do this in production.
An Azure Virtual Machine has several components. In this example we'll build
a security group, a network interface, a public ip address, a storage
account and finally the VM itself. Terraform handles all the dependencies
automatically, and each resource is named with user-defined variables. */

resource "aws_security_group" "vault-sg" {
  name        = "${var.prefix}-sg"
  description = "Vault Security Group"
  vpc_id      = "${aws_vpc.workshop.id}"

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

/* And now we build our Vault server. This is a standard Ubuntu instance.
We use the shell provisioner to run a Bash script that configures Vault for
the demo environment. Terraform supports several different types of
provisioners including Bash, Powershell and Chef. */

resource "aws_instance" "vault-server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.vm_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.vault-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "housaws-tf-workshop"
  tags = {
    Name = "lab-vault-server"
    TTL = "72"
    owner = "Andy James"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
    host = "${aws_instance.vault-server.public_ip}"
  }
  provisioner "file" {
    source      = "files/"
    destination = "/home/ubuntu/"
  }

  provisioner "remote-exec" {
    inline = [
    "chmod -R +x /home/ubuntu/",
    "sleep 30",
    "MYSQL_HOST=${var.prefix}-mysql-server /home/ubuntu/setup.sh"
    ]
  }
}

/* Azure MySQL Database
Vault will manage this database with the database secrets engine.
Terraform can build any type of infrastructure, not just virtual machines.
Azure offers managed MySQL database servers and a whole host of other
resources. Each resource is documented with all the available settings:
https://www.terraform.io/docs/providers/azurerm/r/mysql_server.html */

# resource "azurerm_mysql_server" "mysql" {
#   name                = "${var.prefix}-mysql-server"
#   location            = "${azurerm_resource_group.hashitraining.location}"
#   resource_group_name = "${azurerm_resource_group.hashitraining.name}"
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
# }

/* This is a sample database that we'll populate with data from our app.
With Terraform, everything is Infrastructure as Code. No more manual steps,
aging runbooks, tribal knowledge or outdated wiki instructions. Terraform
is your executable documentation, and it will build infrastructure correctly
every time. */

# resource "azurerm_mysql_database" "wsmysqldatabase" {
#   name                = "wsmysqldatabase"
#   resource_group_name = "${azurerm_resource_group.hashitraining.name}"
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
#   resource_group_name = "${azurerm_resource_group.hashitraining.name}"
#   server_name         = "${azurerm_mysql_server.mysql.name}"
#   start_ip_address    = "${data.azurerm_public_ip.vault-pip.ip_address}"
#   end_ip_address      = "${data.azurerm_public_ip.vault-pip.ip_address}"
# }
