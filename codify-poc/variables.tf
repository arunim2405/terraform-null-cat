variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "s3_buckets" {
  type = map(object({
    bucket = string
    tags   = optional(map(string), {})
  }))
  default = {}
}

variable "security_groups" {
  type = map(object({
    name        = string
    description = string
    vpc_id      = string
    tags        = optional(map(string), {})
  }))
  default = {}
}
