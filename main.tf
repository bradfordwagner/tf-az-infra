provider "azurerm" {
  features {}
}

# resource group for all infrastructure to be added to
resource "azurerm_resource_group" "rg" {
  name     = "bradfordwagner-infra"
  location = "eastus2"
}

# create a kubernetes cluster
module "k8s" {
  depends_on          = [azurerm_resource_group.rg]
  source              = "./modules/k8s_cluster"
  enabled             = false
  resource_group_name = azurerm_resource_group.rg.name
}

# create a blub storage
module "blob_storage" {
  depends_on          = [azurerm_resource_group.rg]
  source              = "./modules/blob_storage"
  enabled             = false
  resource_group_name = azurerm_resource_group.rg.name
  name                = "blubblubblub"
}

module "keyvault" {
  depends_on          = [azurerm_resource_group.rg]
  source              = "./modules/keyvault"
  enabled             = false
  resource_group_name = azurerm_resource_group.rg.name
  name                = "bradfordwagner-test1"
}
