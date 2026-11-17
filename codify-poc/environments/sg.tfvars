buckets = {
  postman982 = {
    bucket = "postman982"
  }
}

security_groups = {
  tf_ansible_sg_20250506132712127200000001 = {
    name        = "tf-ansible-sg-20250506132712127200000001"
    description = "Security Group managed by Terraform"
    vpc_id      = "vpc-01c46493e7453ae92"
    tags = {
      Name = "tf-ansible-sg"
    }
  }
}
