# ADE File Notifier Reference for Azure

## Architecture
A general solution architecture is presented in this diagram:
![image](architecture/azure_notifier.png)

Please refer to the readme file in each [terraform module](terraform/modules/) for detailed lists of resources.

## Deployment
The infrastructure and Function App deployment have been implemented with Terraform.

1. Define your environments in [environments](environments/), see [environments/dev](environments/dev/) for reference. 

2. Define a Terraform state storage for each environment, see [environments/dev/tfstate_storage/README.md](environments/dev/tfstate_storage/README.md).

3. Configure a [backend.conf](environments/dev/backend.conf) and a [terraform.tfvars](environments/dev/terraform.tfvars) file for each environment.

4. Configure your data sources in the [config](../../config/) folder. See [README.md](../../README.md) in the root directory for the configuration format.

5. Run the Terraform deployment per environment as instructed in [terraform/README.md](terraform/README.md).
