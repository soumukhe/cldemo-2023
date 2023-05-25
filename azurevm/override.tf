# Please do not put the Infra account related items for these values
variable "azurestuff" {
  type = map(any)
  default = {
    subscription_id = ""
    client_id       = ""
    client_secret   = ""
    tenant_id       = ""
  }

}
