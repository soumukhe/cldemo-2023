#  Populate values based on your ND cofigiration
variable "creds" {
  type = map(any)
  default = {
    username = "00000000"
    password = "00000000"
    url      = "https://00000000/"
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
    aws_account_id    = "00000000"
    aws_access_key_id = "00000000000000000000"
    aws_secret_key    = "0000000000000000000000000000000000000000"
  }
}

variable "azurestuff" {
  type = object({
    azure_subscription_id = string
  })
  default = {
    azure_subscription_id = "00000000"
  }
}
