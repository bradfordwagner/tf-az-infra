# load in current sp
data "azuread_client_config" "current" {}

# load in existing resource group
data azurerm_resource_group "target" {
  name = var.resource_group_name
}

# setup identity which will be used to access storage account
resource "azurerm_user_assigned_identity" "blob" {
  count               = var.enabled ? 1 : 0
  name                = "blob"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location
}

# setup storage account
resource "azurerm_storage_account" "blob" {
  count                     = var.enabled ? 1 : 0
  name                      = "blubblubblub"
  account_tier              = "Standard"
  account_kind              = "BlobStorage"
  account_replication_type  = "GRS"
  resource_group_name       = data.azurerm_resource_group.target.name
  location                  = data.azurerm_resource_group.target.location
  shared_access_key_enabled = true
  #  identity {
    #    type = "UserAssigned"
    #    identity_ids = [azurerm_user_assigned_identity.blob[0].id]
#  }
}

#resource "azurerm_role_assignment" "identity_blob_contributor" {
#  count                = var.enabled ? 1 : 0
#  principal_id         = azurerm_user_assigned_identity.blob[0].principal_id
#  scope                = azurerm_storage_account.blob[0].id
#  role_definition_name = "Storage Blob Data Contributor"
#}

#resource "azurerm_role_assignment" "sp_blob_contributor" {
#  count                = var.enabled ? 1 : 0
#  principal_id         = data.azuread_client_config.current.object_id
#  scope                = azurerm_storage_account.blob[0].id
#  role_definition_name = "Storage Blob Data Contributor"
#}