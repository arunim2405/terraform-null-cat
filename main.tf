provider "local" {}

resource "null_resource" "cat" {
  provisioner "local-exec" {
    command = "echo 'Meaw meaw meaw meaw woof' > artifact.txt"
  }
}

output "message" {
  value = "Cat meawed successfully!"
}

output "artifact_content" {
  value = file("artifact.txt")
}
