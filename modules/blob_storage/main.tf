# load in current sp
data "azuread_client_config" "current" {}

# load in existing resource group
data azurerm_resource_group "target" {
  name = var.resource_group_name
}

# setup storage account
resource "azurerm_storage_account" "blob" {
  count                     = var.enabled ? 1 : 0
  name                      = var.name
  account_tier              = "Standard"
  account_kind              = "BlobStorage"
  account_replication_type  = "GRS"
  resource_group_name       = data.azurerm_resource_group.target.name
  location                  = data.azurerm_resource_group.target.location
  shared_access_key_enabled = true
}
