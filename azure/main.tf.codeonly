resource "azurerm_resource_group" "vaultworkshop" {
  name     = "${var.prefix}-vault-workshop"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = "${azurerm_resource_group.vaultworkshop.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.vaultworkshop.name}"
  address_prefix       = "${var.subnet_prefix}"
}

resource "azurerm_network_security_group" "vault-sg" {
  name                = "${var.prefix}-sg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"

  security_rule {
    name                       = "Vault"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "${var.vault_source_ips}"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Transit-App"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${var.ssh_source_ips}"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vault-nic" {
  name                      = "${var.prefix}-vault-nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.vaultworkshop.name}"
  network_security_group_id = "${azurerm_network_security_group.vault-sg.id}"

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.vault-pip.id}"
  }
}

resource "azurerm_public_ip" "vault-pip" {
  name                = "${var.prefix}-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}"
}

resource "azurerm_virtual_machine" "vault" {
  name                = "${var.prefix}-vault"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
  vm_size             = "${var.vm_size}"

  network_interface_ids         = ["${azurerm_network_interface.vault-nic.id}"]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.prefix}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "file" {
    source      = "files/setup.sh"
    destination = "/home/${var.admin_username}/setup.sh"

    connection {
      type     = "ssh"
      user     = "${var.admin_username}"
      password = "${var.admin_password}"
      host     = "${azurerm_public_ip.vault-pip.fqdn}"
    }
  }

  provisioner "file" {
    source      = "files/vault_setup.sh"
    destination = "/home/${var.admin_username}/vault_setup.sh"

    connection {
      type     = "ssh"
      user     = "${var.admin_username}"
      password = "${var.admin_password}"
      host     = "${azurerm_public_ip.vault-pip.fqdn}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.admin_username}/*.sh",
      "sleep 30",
      "MYSQL_HOST=${var.prefix}-mysql-server /home/${var.admin_username}/setup.sh"
    ]

    connection {
      type     = "ssh"
      user     = "${var.admin_username}"
      password = "${var.admin_password}"
      host     = "${azurerm_public_ip.vault-pip.fqdn}"
    }
  }
}

resource "azurerm_mysql_server" "mysql" {
  name                = "${var.prefix}-mysql-server"
  location            = "${azurerm_resource_group.vaultworkshop.location}"
  resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
  ssl_enforcement     = "Disabled"

  sku {
    name     = "B_Gen5_2"
    capacity = 2
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "${var.admin_username}"
  administrator_login_password = "${var.admin_password}"
  version                      = "5.7"
  ssl_enforcement              = "Disabled"
}

resource "azurerm_mysql_database" "wsmysqldatabase" {
  name                = "wsmysqldatabase"
  resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
  server_name         = "${azurerm_mysql_server.mysql.name}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

data "azurerm_public_ip" "vault-pip" {
  name                = "${azurerm_public_ip.vault-pip.name}"
  depends_on          = ["azurerm_virtual_machine.vault"]
  resource_group_name = "${azurerm_virtual_machine.vault.resource_group_name}"
}

resource "azurerm_mysql_firewall_rule" "vault-mysql" {
  name                = "vault-mysql"
  resource_group_name = "${azurerm_resource_group.vaultworkshop.name}"
  server_name         = "${azurerm_mysql_server.mysql.name}"
  start_ip_address    = "${data.azurerm_public_ip.vault-pip.ip_address}"
  end_ip_address      = "${data.azurerm_public_ip.vault-pip.ip_address}"
}
