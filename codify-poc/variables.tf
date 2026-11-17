variable "buckets" {
  description = "S3 buckets, keyed by sanitized name."
  type = map(object({
    bucket = string
    tags   = optional(map(string), {})
  }))
  default = {}
}

variable "security_groups" {
  description = "EC2 security groups, keyed by sanitized Name tag."
  type = map(object({
    name        = string
    description = string
    vpc_id      = string
    tags        = optional(map(string), {})
  }))
  default = {}
}
