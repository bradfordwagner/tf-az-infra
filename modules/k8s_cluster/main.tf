
# load in existing resource group
data azurerm_resource_group "target" {
  name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "aks" {
  count               = var.enabled ? 1 : 0
  name                = "aks"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location
}

resource "azurerm_kubernetes_cluster" "infra" {
  count               = var.enabled ? 1 : 0
  name                = "infra"
  location            = data.azurerm_resource_group.target.location
  resource_group_name = data.azurerm_resource_group.target.name
  dns_prefix          = "bradfordwagner"
  kubernetes_version  = var.k8s_version

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard" # basic made it unable to connect k9s
  }

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_B8ms" # burstables
    node_count = var.node_count

    orchestrator_version = var.k8s_version
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks[0].id]
  }

  tags = {
    Environment = "dev"
  }
}
