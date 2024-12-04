

Make sure to have these:
```
gcloud auth login
gcloud config set project hanki-2694-ade-proservicesdemo 

gcloud auth application-default login --project hanki-2694-ade-proservicesdemo
```

### DEV
```
terraform init -backend-config=../environments/dev/backend.conf


terraform plan -var-file="../environments/dev/terraform.tfvars"


terraform apply -var-file="../environments/dev/terraform.tfvars"
```


### DEV
```
gcloud auth application-default login --project hanki-2832-adeproservdemo-prod
terraform init -backend-config=../environments/prod/backend.conf


terraform plan -var-file="../environments/prod/terraform.tfvars"


terraform apply -var-file="../environments/prod/terraform.tfvars"
```