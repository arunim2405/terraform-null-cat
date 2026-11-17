variable "bucket" {
  description = "Bucket name."
  type        = string
}

variable "tags" {
  description = "Bucket tags."
  type        = map(string)
  default     = {}
}
