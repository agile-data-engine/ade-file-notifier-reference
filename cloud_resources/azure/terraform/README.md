## Azure login
```
az login --tenant 12d0df3c-a73c-4e76-98a7-814d85f14fac
az account set --subscription 74260aef-bffb-47fe-862b-a1a04aea52ab
```

### DEV
```
terraform init -backend-config=../environments/dev/backend.conf

terraform plan -var-file="../environments/dev/terraform.tfvars"

terraform apply -var-file="../environments/dev/terraform.tfvars"
```