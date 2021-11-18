

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = "East US"

  tags = {
    managedby = var.tags
  }
} 

#Configure Azure storage for backend state

resource "azurerm_storage_account" "stg01" {
  name                     = "${var.prefix}${var.environment}stg"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    managedby = var.tags
  }
}

resource "azurerm_storage_container" "ctn" {
  name                  = "${var.prefix}${var.environment}ctn"
  storage_account_name  = azurerm_storage_account.stg01.name

   #lifecycle {
    #prevent_destroy = true
  #}
}
  