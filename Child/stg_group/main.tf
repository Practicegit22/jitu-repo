
resource "azurerm_storage_account" "shivastg" {
  name                     = "shivastgaccount"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
