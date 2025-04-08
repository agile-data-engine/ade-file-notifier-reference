# TFstate
Using Azure CLI to create a resource group, a storage account and a container for remote tfstate.
Create if one does not exist yet.

Azure login:
```
az login --tenant <tenant_id>
az account set --subscription <subscription_id>
```

Create a storage account & container:
```
az group create --location <region> --name <rgnamedev>
az storage account create -n <staccountnamedev> -g <rgnamedev> -l <region> --sku Standard_LRS --allow-shared-key-access false
az storage container create -n tfstate --account-name <staccountnamedev> --public-access off --auth-mode login
```

Assign the `Storage Blob Data Contributor` role to yourself or to the identity you are using:
```
az role assignment create \
  --assignee <your-object-id> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/subscriptionid/resourceGroups/<rgnamedev>/providers/Microsoft.Storage/storageAccounts/<staccountnamedev>
```