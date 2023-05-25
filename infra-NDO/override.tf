#  Populate values based on your ND cofigiration
variable "creds" {
  type = map(any)
  default = {
    username = "admin"
    password = ""
    url      = "https://ipOfNDO/"
    domain   = "local" #  if you don't have remote authentication setup, just put the value  local
  }
}

# for aws tenant.  Note we don't need the access keys and secret IDs since we have established trust relationship between Infra and Tenant already
variable "awsstuff" {
  type = object({
    aws_account_id    = string
    aws_access_key_id = string
    aws_secret_key    = string
  })
  default = {
    aws_account_id    = ""
    aws_access_key_id = "00000000000000000000"
    aws_secret_key    = "0000000000000000000000000000000000000000"
  }
}

variable "azurestuff" {
  type = object({
    azure_subscription_id = string
  })
  default = {
    azure_subscription_id = ""
  }
}
