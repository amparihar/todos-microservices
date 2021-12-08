## Terraform Versions
-----------------------------
https://releases.hashicorp.com/terraform

## Linux Install
-----------------------------
curl -O https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
sudo unzip terraform_1.0.0_linux_amd64.zip
sudo mv terraform /usr/local/bin
            OR
sudo unzip terraform_1.0.0_linux_amd64.zip -d /usr/local/bin

terraform version

terraform init
terraform validate
terraform plan -out out.plan
terraform apply out.plan

terraform destroy
