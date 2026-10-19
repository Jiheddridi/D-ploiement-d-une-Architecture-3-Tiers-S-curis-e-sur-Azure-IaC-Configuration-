resource "azurerm_resource_group" "main" {
  name     = "lerg${var.environment}"
  location = var.location
  tags     = var.tags
}
