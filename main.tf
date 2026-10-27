provider "local" {}

variable "artifact_content" {
  description = "Content to be written to the artifact file"
  type        = string
  default     = "This is an artifact created by Terraform"
}

variable "cat_name" {
  description = "Name of the cat"
  type        = string
  default     = "Ghost"
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo '${var.artifact_content}' > artifact.txt"
  }
}

resource "local_file" "artifact" {
  content  = var.artifact_content
  filename = "${path.module}/artifact.txt"
}

output "cat_ghost" {
  value = "Ghost meawed successfully!"
}


output "cat_is_not_ghost" {
  value = "Ghost meawed successfully!"
}

output "artifact_content" {
  value = local_file.artifact.content
}

output "cat_name" {
  value = var.cat_name
}

variable "secret_in" {
  description = "Sensitive input used by the secret masking tests"
  type        = string
  sensitive   = true
}

resource "null_resource" "secret_holder" {
  triggers = {
    s = var.secret_in
  }
}

output "secret_out" {
  value     = var.secret_in
  sensitive = true
}

output "secret_passthrough" {
  value = nonsensitive(var.secret_in)
}
