#########################################################
# VARIABLES
#########################################################
variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "rg-checkov-demo"
}

#########################################################
# RESOURCE GROUP
#########################################################
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

#########################################################
# VIRTUAL NETWORK & SUBNET
#########################################################
resource "azurerm_virtual_network" "main" {
  name                = "vnet-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "subnet-demo"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

#########################################################
# NETWORK SECURITY GROUP
#########################################################
resource "azurerm_network_security_group" "main" {
  name                = "nsg-demo"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "DenyRDPInternet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

#########################################################
# STORAGE ACCOUNT (for SQL VA)
#########################################################
resource "azurerm_storage_account" "main" {
  name                     = "checkovstorage123"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#########################################################
# SQL SERVER
#########################################################
resource "azurerm_mssql_server" "sql" {
  name                         = "sqlservercheckov"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "P@ssw0rd12345!"
}

#########################################################
# SQL SERVER SECURITY ALERT POLICY
#########################################################
resource "azurerm_mssql_server_security_alert_policy" "sql_policy" {
  resource_group_name        = azurerm_mssql_server.sql.resource_group_name
  server_name                = azurerm_mssql_server.sql.name
  state                      = "Enabled"
  email_account_admins       = true
  storage_endpoint           = azurerm_storage_account.main.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  retention_days             = 90
}

#########################################################
# SQL SERVER VULNERABILITY ASSESSMENT
#########################################################
resource "azurerm_mssql_server_vulnerability_assessment" "sql_va" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sql_policy.id

  recurring_scans {
    email_subscription_admins = true
   
  }

  storage_container_path = "${azurerm_storage_account.main.primary_blob_endpoint}vulnerability-assessment/"
}
