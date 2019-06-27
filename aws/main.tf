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

resource "aws_vpc" "workshop" {
  cidr_block       = "${var.address_space}"
  tags = {
    Name = "${var.prefix}-workshop"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.workshop.id}"
  cidr_block = "${var.subnet_prefix}"

  tags = {
    Name = "${var.prefix}-workshop-subnet"
  }
}


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

resource "aws_instance" "vault-server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.vm_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.vault-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "housaws-tf-workshop"
  tags = {
    Name = "#{var.prefix}-tf-workshop"
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

resource "aws_db_instance" "vault-demo" {
  allocated_storage    = 20
  identifier           = "${var.prefix}-tf-workshop-rds"
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "wsmysqldatabase"
  username             = "hashicorp"
  password             = "Password123!"
  parameter_group_name = "default.mysql5.7"
}

/* Allows the Linux VM to connect to the MySQL database, using the IP address
from the data source above. */

# resource "azurerm_mysql_firewall_rule" "vault-mysql" {
#   name                = "vault-mysql"
#   resource_group_name = "${azurerm_resource_group.hashitraining.name}"
#   server_name         = "${azurerm_mysql_server.mysql.name}"
#   start_ip_address    = "${data.azurerm_public_ip.vault-pip.ip_address}"
#   end_ip_address      = "${data.azurerm_public_ip.vault-pip.ip_address}"
# }
