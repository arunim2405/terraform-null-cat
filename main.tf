provider "local" {}

variable "artifact_content" {
  description = "Content to be written to the artifact file"
  type        = string
  default     = "This is an artifact created by Terraform"
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo '${var.artifact_content}' > artifact.txt"
  }
}

output "message" {
  value = "Cat meawed successfully!"
}

output "artifact_content" {
  value = file("artifact.txt")
}
