#create the compute resources

resource "azurerm_availability_set" "avs01" {
  name                = "avs"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = {
    managedby = var.tags
  }
}

#create ip address for controller vms

resource "azurerm_public_ip" "ctrlpip" {
  name                = "${var.prefix}-${var.environment}-ctrlpip${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  count = var.ctrlvm_count

  tags = {
    managedby = var.tags
  }
}

#create network interfaces for the controller vms

resource "azurerm_network_interface" "ctrlnic" {
  name                 = "${var.prefix}-${var.environment}-ctrlnic${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  enable_ip_forwarding = true
  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.1${count.index + 1}"
    public_ip_address_id          = azurerm_public_ip.ctrlpip[count.index].id
  }

  count = var.ctrlvm_count

  tags = {
    managedby = var.tags
  }
}

#create ssh keys

resource "tls_private_key" "eutu_dev_key" {
    algorithm = "RSA"
    rsa_bits  = "4096"
}

output "tls_private_key" { 
  value = tls_private_key.eutu_dev_key.private_key_pem
  sensitive = true
}
#create controller vms

resource "azurerm_linux_virtual_machine" "ctrlvm" {
  name                  = "${var.prefix}-${var.environment}-ctrlvm${count.index + 1}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.ctrlvm_size
  availability_set_id   = azurerm_availability_set.avs01.id
  admin_username        = "usr1"
  #admin_password = "Azure01"
  network_interface_ids = [azurerm_network_interface.ctrlnic[count.index].id]
  disable_password_authentication = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.prefix}-${var.environment}-ctrldisk${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.ctrl_disk_size_gb
  }

  admin_ssh_key {
    username   = "usr1"
    public_key = tls_private_key.eutu_dev_key.public_key_openssh
  }

  count = var.ctrlvm_count

  tags = {
    managedby = var.tags
  }
}

#create worker node public address 

resource "azurerm_public_ip" "wkrpip" {
  name                = "${var.prefix}-${var.environment}-wkrpip${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  count = var.wkr_vm_count

  tags = {
    managedby = var.tags
  }
}

resource "azurerm_network_interface" "wkrnic" {
  name                 = "${var.prefix}-${var.environment}-wkrnic${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  enable_ip_forwarding = true
  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.2${count.index + 1}"
    public_ip_address_id          = azurerm_public_ip.wkrpip[count.index].id
  }

  count = var.wkr_vm_count

  tags = {
    managedby = var.tags
  }
}

#create vorker vms

resource "azurerm_linux_virtual_machine" "wrkervm" {
  name                  = "${var.prefix}-${var.environment}-wkrvm${count.index + 1}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.wkr_vm_size
  admin_username        = "usr1"
  #admin_password = "Azure01"
  network_interface_ids = [azurerm_network_interface.wkrnic[count.index].id]
  disable_password_authentication = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.prefix}-${var.environment}-wkrdisk${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.wkr_disk_size_gb
  }

  admin_ssh_key {
    username   = "usr1"
    public_key = tls_private_key.eutu_dev_key.public_key_openssh

  }


  count      = var.wkr_vm_count
  depends_on = [azurerm_linux_virtual_machine.ctrlvm, azurerm_lb_rule.lbr01]

  tags = {
    managedby = var.tags
  }
}

#create load balancer public ip

resource "azurerm_public_ip" "lbpip" {
  name                = "${var.prefix}-${var.environment}-lbpip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    managedby = var.tags
  }
}

#create network load balancer

resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-${var.environment}-lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "${var.prefix}-${var.environment}-apiserver"
    public_ip_address_id = azurerm_public_ip.lbpip.id
  }

  tags = {
    managedby = var.tags
  }
}

#create load balancer backend pool

resource "azurerm_lb_backend_address_pool" "bap" {
  name                = "${var.prefix}-${var.environment}-bap"
  loadbalancer_id     = azurerm_lb.lb.id
}

#associate backend pool with nic of master nodes

resource "azurerm_network_interface_backend_address_pool_association" "bapa" {
  network_interface_id    = azurerm_network_interface.ctrlnic[count.index].id
  ip_configuration_name   = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bap.id

  count = var.ctrlvm_count
}

#create load balancer probe

resource "azurerm_lb_probe" "lbp" {
  name                = "${var.prefix}-${var.environment}-lbp"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
}

#create load balancer rule

resource "azurerm_lb_rule" "lbr01" {
  name                           = "lbr"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = "${var.prefix}-${var.environment}-apiserver"
  protocol                       = "Tcp"
  frontend_port                  = "6443"
  backend_port                   = "6443"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bap.id

  # attach health probe
  probe_id = azurerm_lb_probe.lbp.id

}

