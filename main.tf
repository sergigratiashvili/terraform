locals {
  rg_name               = "rg-${var.RESOURCE_NAME_PREFIX}-${var.LOCATION}-${var.ENV}"
  app_service_plan_name = "plan-${var.RESOURCE_NAME_PREFIX}-${var.LOCATION}-${var.ENV}"
  app_service_name      = "app-${var.RESOURCE_NAME_PREFIX}-${var.LOCATION}-${var.ENV}"
  sql_server_name       = "sql-${var.RESOURCE_NAME_PREFIX}-${var.LOCATION}-${var.ENV}"
  sql_db_name           = "sqldb-${var.RESOURCE_NAME_PREFIX}-${var.LOCATION}-${var.ENV}"
}


### Creates resource group
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.LOCATION
}

# Deploys app service plan.
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = local.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = var.kind

  sku {
    tier = var.sku_tier
    size = var.sku_size
  }
}

# Deploys Azure web appliaction with connection string to previously created SQL database
resource "azurerm_app_service" "app_service" {
  name                = local.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings        = {}

  connection_string {
    name  = var.connection_string_name
    type  = "SQLAzure"
    value = "Server=tcp:${azurerm_sql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.sql_db.name};Persist Security Info=False;User ID=${var.SQL_SERVER_ADMINISTRATOR_LOGIN};Password=${var.SQL_SERVER_ADMINISTRATOR_PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}

resource "azurerm_app_service_slot" "app_service" {
  name                = local.app_service_name
  app_service_name    = azurerm_app_service.app_service.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings        = {}

  connection_string {
    name  = var.connection_string_name
    type  = "SQLAzure"
    value = "Server=tcp:${azurerm_sql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.sql_db.name};Persist Security Info=False;User ID=${var.SQL_SERVER_ADMINISTRATOR_LOGIN};Password=${var.SQL_SERVER_ADMINISTRATOR_PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}

### Creates Azure SQL server
resource "azurerm_sql_server" "sql_server" {
  name                         = local.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = var.sql_server_version
  administrator_login          = var.SQL_SERVER_ADMINISTRATOR_LOGIN
  administrator_login_password = var.SQL_SERVER_ADMINISTRATOR_PASSWORD
  connection_policy            = var.sql_server_connection_policy
}

### Creates Azure SQL server firewall rule
resource "azurerm_sql_firewall_rule" "sql_server" {
  for_each = var.sql_server_firewall_rules

  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql_server.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

### Creates Azure SQL database
resource "azurerm_sql_database" "sql_db" {
  name                = local.sql_db_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql_server.name
  edition             = var.edition
  collation           = var.collation
  max_size_bytes      = var.max_size_bytes
  zone_redundant      = var.zone_redundant
}