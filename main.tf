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

resource "terraform_data" "dump_installed_packages" {
  triggers_replace = {
    run_always = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]

    command = <<-EOT
      set -eu
      cat /etc/os-release 2>/dev/null || true

      if command -v dpkg-query >/dev/null 2>&1; then
        dpkg-query -W -f='$${binary:Package}\t$${Version}\n' | sort
      elif command -v rpm >/dev/null 2>&1; then
        rpm -qa | sort
      elif command -v apk >/dev/null 2>&1; then
        apk list --installed | sort
      else
        echo "No supported package manager found."
      fi
    EOT
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
