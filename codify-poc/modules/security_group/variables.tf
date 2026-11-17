variable "name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
}

variable "vpc_id" {
  description = "VPC the group belongs to."
  type        = string
}

variable "tags" {
  description = "Security group tags."
  type        = map(string)
  default     = {}
}
