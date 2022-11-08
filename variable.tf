### Variables that should be specified.
variable "LOCATION" {}
variable "RESOURCE_NAME_PREFIX" {}
variable "ENV" {}
variable "SQL_SERVER_ADMINISTRATOR_LOGIN" {}
variable "SQL_SERVER_ADMINISTRATOR_PASSWORD" {
  sensitive = true
}

### Variables that have some default values but also acn be specified if you'd like.
variable "sql_server_version" {
  default = "12.0"
}
variable "sql_server_connection_policy" {
  default = "Default"
}
variable "sql_server_firewall_rules" {
  type = map(any)
  default = {
    allow_azure_services = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }
}
variable "edition" {
  default = "Basic"
}
variable "collation" {
  default = "SQL_Latin1_General_CP1_CI_AS"
}
variable "max_size_bytes" {
  default = "104857600"
}
variable "zone_redundant" {
  type    = bool
  default = false
}
variable "kind" {
  default = "Windows"
}
variable "sku_tier" {
  default = "Standard"
}
variable "sku_size" {
  default = "S1"
}
variable "connection_string_name" {
  default = "MyDbConnection"
}