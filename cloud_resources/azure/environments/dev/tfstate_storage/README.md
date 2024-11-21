# TFstate
Using Azure CLI to create a resource group, a storage account and a container for remote tfstate.
Create if one does not exist yet.

## Azure login
```
az login --tenant 12d0df3c-a73c-4e76-98a7-814d85f14fac
az account set --subscription 74260aef-bffb-47fe-862b-a1a04aea52ab
```

## Create storage account & container
```
az group create --location northeurope --name "rg-ade-reference-notifier-dev"
az storage account create -n "staderefnotiftfstatedev" -g "rg-ade-reference-notifier-dev" -l northeurope --sku Standard_LRS --allow-shared-key-access false
az storage container create -n tfstate --account-name "staderefnotiftfstatedev" --public-access off --auth-mode login
```

## Assign Storage Blob Data Contributor role to yourself
```
az role assignment create \
  --assignee <your-object-id> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/74260aef-bffb-47fe-862b-a1a04aea52ab/resourceGroups/rg-ade-reference-notifier-dev/providers/Microsoft.Storage/storageAccounts/staderefnotiftfstatedev
```