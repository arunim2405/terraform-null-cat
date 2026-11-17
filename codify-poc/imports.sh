#!/bin/sh
set -e
"$1" import -var-file environments/sg.tfvars 'module.security_group["tf_ansible_sg"].aws_security_group.this' 'sg-02a99a46210d46252'
"$1" import -var-file environments/sg.tfvars 'module.bucket["postman982"].aws_s3_bucket.this' 'postman982'
