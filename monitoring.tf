resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-3tier"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "sql" {
  name                       = "diag-sql"
  target_resource_id         = azurerm_mssql_database.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log { category = "SQLSecurityAuditEvents" }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}
