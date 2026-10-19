
# ==========================================
# 1. PUBLIC IP POUR AZURE BASTION
# ==========================================

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# ==========================================
# 2. AZURE BASTION
# ==========================================

resource "azurerm_bastion_host" "main" {
  name                = "bastion-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

# ==========================================
# 3. PUBLIC IP POUR LOAD BALANCER
# ==========================================

resource "azurerm_public_ip" "lb_web" {
  name                = "pip-lb-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# ==========================================
# 4. LOAD BALANCER PUBLIC
# ==========================================

resource "azurerm_lb" "web" {
  name                = "lb-web-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb_web.id
  }

  tags = var.tags
}

# ==========================================
# 5. BACKEND POOL DU LOAD BALANCER
# ==========================================

resource "azurerm_lb_backend_address_pool" "web" {
  name            = "backend-pool-web"
  loadbalancer_id = azurerm_lb.web.id
}

# ==========================================
# 6. PUBLIC IP POUR NAT GATEWAY
# ==========================================

resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# ==========================================
# 7. NAT GATEWAY
# ==========================================

resource "azurerm_nat_gateway" "main" {
  name                = "nat-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard"

  tags = var.tags
}

# ==========================================
# 8. ASSOCIATION PUBLIC IP - NAT GATEWAY
# ==========================================

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# ==========================================
# 9. ASSOCIATION NAT GATEWAY - SUBNET WEB
# ==========================================

resource "azurerm_subnet_nat_gateway_association" "web" {
  subnet_id      = azurerm_subnet.this["web"].id
  nat_gateway_id = azurerm_nat_gateway.main.id
}
