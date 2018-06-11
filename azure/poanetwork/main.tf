# Configure the Azure Provider
provider "azurerm" {
  version = "1.6.0"
}

resource "azurerm_resource_group" "poa" {
  count    = "${var.prepare_resource_group}"
  
  name     = "${var.resource_group_name}"
  location = "${var.region}"

  tags {
    environment = "${var.environment_name}"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "poa" {
  name                = "${var.prefix}poa-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"

  tags {
    environment = "${var.environment_name}"
  }
}

# Create subnet
resource "azurerm_subnet" "poa" {
  name                 = "${var.prefix}poa-subnet"
  resource_group_name  = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.poa.name}"
  address_prefix       = "10.0.1.0/24"
}

module "bootnode-lb" {

  source = "./modules/node"

  resource_group_name = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"
  
  network_name = "${var.network_name}"
  subnet_id    = "${azurerm_subnet.poa.id}"
  lb_node_count   = "${var.bootnode_lb_count}"
  region       = "${var.region}"
  
  platform     = "ubuntu"
  role         = "bootnode-lb"
  ssh_public_key = "${var.ssh_public_key}"
 
}

module "bootnode-lb-balancing" {

  source = "./modules/lb"

  resource_group_name = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"
  
  lb_node_count = "${var.bootnode_lb_count}"
  region        = "${var.region}"  
  role          = "bootnode-lb"
 
}

module "bootnode" {
  source = "./modules/node"

  resource_group_name = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"
  
  network_name = "${var.network_name}"
  subnet_id    = "${azurerm_subnet.poa.id}"
  node_count   = "${var.bootnode_count}"
  region       = "${var.region}"
  
  platform     = "ubuntu"
  role         = "bootnode"
  ssh_public_key = "${var.ssh_public_key}"
  
}

module "explorer" {
  source = "./modules/node"

  resource_group_name = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"

  network_name = "${var.network_name}"
  subnet_id    = "${azurerm_subnet.poa.id}"
  node_count   = 1
  region       = "${var.region}"  

  platform     = "ubuntu"
  role         = "explorer"
  ssh_public_key = "${var.ssh_public_key}"
  
}


module "moc" {
  source = "./modules/node"

  resource_group_name = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"

  network_name = "${var.network_name}"
  subnet_id    = "${azurerm_subnet.poa.id}"
  node_count   = 1
  region       = "${var.region}" 
  
  platform     = "ubuntu"
  role         = "moc"  
  ssh_public_key = "${var.ssh_public_key}"
  
}

module "netstat" {
  source = "./modules/node"

  resource_group_name = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"

  network_name = "${var.network_name}"
  subnet_id    = "${azurerm_subnet.poa.id}"
  node_count   = 1
  region       = "${var.region}" 

  platform     = "ubuntu"
  role         = "netstat"  
  ssh_public_key = "${var.ssh_public_key}"

}


module "validator" {
  source = "./modules/node"

  resource_group_name = "${azurerm_resource_group.poa.count > 0 ? element(concat(azurerm_resource_group.poa.*.name, list("")), 0) : var.resource_group_name}"

  network_name = "${var.network_name}"
  subnet_id    = "${azurerm_subnet.poa.id}"
  node_count   = "${var.validator_count}"
  region       = "${var.region}" 
  
  platform     = "ubuntu"
  role         = "validator"  
  ssh_public_key = "${var.ssh_public_key}"
  
}
