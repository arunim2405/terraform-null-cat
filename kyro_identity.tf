provider "aws" { region = "eu-central-1" }
data "aws_caller_identity" "kyro" {}
output "kyro_caller_arn" { value = data.aws_caller_identity.kyro.arn }
