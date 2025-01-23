## Azure login
```
az login --tenant tenant_id
az account set --subscription subscription_id
```

## Set API secrets as environment variables
```
export TF_VAR_notify_api_key=secret_value
export TF_VAR_notify_api_key_secret=secret_value
export TF_VAR_external_api_key=secret_value
export TF_VAR_external_api_key_secret=secret_value
```

## DEV deployment
```
terraform init -backend-config=../environments/dev/backend.conf

terraform plan -var-file="../environments/dev/terraform.tfvars"

terraform apply -var-file="../environments/dev/terraform.tfvars"
```

## Cleanup generated function files before running apply again
```
rm -rf .output/
```

## DEV destroy
```
terraform destroy -var-file="../environments/dev/terraform.tfvars"
```