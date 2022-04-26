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

# create a kubernetes cluster
module "blob_storage" {
  depends_on          = [azurerm_resource_group.rg]
  source              = "./modules/blob_storage"
  enabled             = true
  resource_group_name = azurerm_resource_group.rg.name
}

module "keyvault" {
  depends_on          = [azurerm_resource_group.rg]
  source              = "./modules/keyvault"
  enabled             = true
  resource_group_name = azurerm_resource_group.rg.name
  keyvault_name       = "bradfordwagner-test1"
}