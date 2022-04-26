# load in current sp
data "azuread_client_config" "current" {}

# load in existing resource group
data azurerm_resource_group "target" {
  name = var.resource_group_name
}

resource "azurerm_key_vault" "keyvault" {
  name                        = var.keyvault_name
  resource_group_name         = data.azurerm_resource_group.target.name
  location                    = data.azurerm_resource_group.target.location
  enabled_for_disk_encryption = true
  tenant_id                   = data.azuread_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

#  access_policy {
#    tenant_id = data.azuread_client_config.current.tenant_id
#    object_id = data.azuread_client_config.current.object_id
#    key_permissions = [
#      "Get",
#    ]
#
#    secret_permissions = [
#      "Get",
#    ]
#
#    storage_permissions = [
#      "Get",
#    ]
#  }
}
