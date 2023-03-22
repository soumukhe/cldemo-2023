
# Note all AWS account related information should be for the AWS account where Tenant will be spun up.  
# Please do not put the Infra account related items for these values

variable "awsstuff" {
  type = map(any)
  default = {
    aws_account_id         = "0000000000"
    is_aws_account_trusted = false
    aws_access_key_id      = "0000000000"
    aws_secret_key         = "0000000000"
  }
}
