resource "random_id" "suffix" {
  byte_length = 3   # => 6 caractères hex, ex: "a1b2c3"
}

resource "random_password" "sql" {
  length           = 20
  special          = true
  override_special = "!#%*-_"
}
