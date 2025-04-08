# Terraform deployment

Azure login:
```
az login --tenant <tenant_id>
az account set --subscription <subscription_id>
```

Set API secrets as environment variables:
```
export TF_VAR_notify_api_key=<secret_value>
export TF_VAR_notify_api_key_secret=<secret_value>
export TF_VAR_external_api_key=<secret_value>
export TF_VAR_external_api_key_secret=<secret_value>
```

Deploy DEV environment:
```
terraform init -backend-config=../environments/dev/backend.conf

terraform plan -var-file="../environments/dev/terraform.tfvars"

terraform apply -var-file="../environments/dev/terraform.tfvars"
```

Note that role assignments may take a while to take effect. If terraform apply fails due to failed blob uploads, try running it again.

Cleanup generated local function files before running apply again:
```
rm -rf .output/
```

Update Terraform modules if needed:
```
terraform get -update
```

Destroy DEV deployment if needed:
```
terraform destroy -var-file="../environments/dev/terraform.tfvars"
```

# Function App deployment

Azure login:
```
az login --tenant <tenant_id>
az account set --subscription <subscription_id>
```

Deploy Function App:
```
az functionapp deployment source config-zip \
--resource-group <rg-name> \
--name <function-app-name> \
--src ./.output/app.zip \
--build-remote true
```