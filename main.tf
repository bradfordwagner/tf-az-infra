
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "bradfordwagner-infra"
  location = var.region
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_kubernetes_cluster" "infra" {
  name                = "infra"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "bradfordwagner"
  kubernetes_version  = "1.21.9"

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard" # basic made it unable to connect k9s
  }

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_B2ms" # burstables
#   vm_size    = "standard_d2a_v4"
    node_count = var.node_count

    # if using scaling
    #enable_auto_scaling  = false
    #min_count            = 1
    #max_count            = 2
    orchestrator_version = "1.21.9"
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks.id
  }

  tags = {
    Environment = "dev"
  }
}
