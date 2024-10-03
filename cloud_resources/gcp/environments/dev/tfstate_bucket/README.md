## TFstate
 
Terraform to create bucket for remote tfstate.
Create if there does not exist one yet.

```
gcloud auth application-default login --project hanki-2694-ade-proservicesdemo

terraform init

terraform plan -var-file=../terraform.tfvars -compact-warnings

terraform apply -var-file=../terraform.tfvars -compact-warnings
```