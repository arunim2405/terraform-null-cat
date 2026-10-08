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

resource "null_resource" "example2" {
  provisioner "local-exec" {
    command = "echo '${var.artifact_content}' > artifact2.txt"
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

output "crazy_nested_output" {
  value = {
    nested = {
      level1 = {
        level2 = {
          "0498" = "This is a deeply nested output"
        }
      }
    }
  }

}

output "nested_list_output" {
  value = [
    "This is a list output",
    "It contains multiple items",
    "Each item is a string"
  ]

}

output "artifact_content" {
  value = local_file.artifact.content
}
