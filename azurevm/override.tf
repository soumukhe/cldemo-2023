# Please do not put the Infra account related items for these values
variable "azurestuff" {
  type = map(any)
  default = {
    subscription_id = "00000000"
    client_id       = "00000000"
    client_secret   = "00000000"
    tenant_id       = "00000000"
  }

}
