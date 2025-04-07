module "function_files" {
    source = "git::https://github.com/agile-data-engine/ade-file-notifier-reference.git//cloud_resources/azure/terraform/modules/function_files?ref=dev_azure_4_2025"
    config_folder = var.config_folder
    config_prefix = var.config_prefix
    function_folder = var.function_folder
    storage_account_name = var.storage_account_name
    storage_container_name = var.container_name
}

data "archive_file" "function_archive" {
  depends_on = [module.function_files]
  type        = "zip"
  output_path = "${path.root}/.output/app.zip" 
  source_dir = module.function_files.function_output_folder
}

resource "azurerm_function_app_flex_consumption" "notifier" {
    location = var.location
    name = "func-${var.app}-${var.env}"
    resource_group_name = var.rg
    service_plan_id = var.asp_id
    storage_container_type = "blobContainer"
    storage_container_endpoint  = "${var.storage_primary_blob_endpoint}${var.container_name}"
    storage_authentication_type = "SystemAssignedIdentity"
    runtime_name = "python"
    runtime_version = "3.11"
    maximum_instance_count = 40
    instance_memory_in_mb = 2048
    tags = var.tags
    virtual_network_subnet_id = var.subnet_id

    identity {
        type = "SystemAssigned"
    }

    site_config {
        application_insights_connection_string = azurerm_application_insights.notifier.connection_string
        cors {
            # Allows functions to be triggered manually in Azure portal
            allowed_origins = ["https://portal.azure.com"]
        }

        dynamic "ip_restriction" {
            for_each = var.allowed_cidr_ranges
            content {
                ip_address = ip_restriction.value
                action     = "Allow"
                priority   = 100
                name       = "AllowedIP_${ip_restriction.key}"
            }
        }

        dynamic "ip_restriction" {
            for_each = var.allowed_subnet_ids
            content {
                virtual_network_subnet_id = ip_restriction.value
                action                    = "Allow"
                priority                  = 100
                name                      = "AllowedVNet_${ip_restriction.key}"
            }
        }

        ip_restriction_default_action = "Deny"
    }

    app_settings = {
        AzureWebJobsDisableHomepage = true
        AzureWebJobsStorage__accountName = var.storage_account_name
        AzureWebJobsStorage__credential = "managedidentity"
        AzureWebJobsStorage__blobServiceUri = var.storage_primary_blob_endpoint
        AzureWebJobsStorage__queueServiceUri = var.storage_primary_queue_endpoint
        AzureWebJobsStorage__tableServiceUri = var.storage_primary_table_endpoint
        remoteBuild = true
        blob_event_queue = var.blob_event_queue
        notify_queue = var.notify_queue
        container_name = var.container_name
        config_prefix = var.config_prefix
        notify_api_base_url = var.notify_api_base_url
        external_api_base_url = var.external_api_base_url
        key_vault_uri = var.key_vault_uri
    }
}

# AzureWebJobsStorage app setting removal, added automatically and cannot be suppressed, prevents app from connecting to storage
# Possibly fixed in future azurerm provider or function app releases (7.4.2025)
resource "null_resource" "remove_azurewebjobsstorage" {
    provisioner "local-exec" {
        command = "az functionapp config appsettings delete --name func-${var.app}-${var.env} --resource-group ${var.rg} --setting-names AzureWebJobsStorage"
    }
    depends_on = [ azurerm_function_app_flex_consumption.notifier ]
}

resource "azurerm_role_assignment" "notifier-storage-contributor" {
    principal_id         = azurerm_function_app_flex_consumption.notifier.identity[0].principal_id
    role_definition_name = "Storage Account Contributor"
    scope                = var.storage_account_id
}

resource "azurerm_role_assignment" "notifier-blob-owner" {
    principal_id         = azurerm_function_app_flex_consumption.notifier.identity[0].principal_id
    role_definition_name = "Storage Blob Data Owner"
    scope                = var.storage_account_id
}

resource "azurerm_role_assignment" "notifier-queue-contributor" {
    principal_id         = azurerm_function_app_flex_consumption.notifier.identity[0].principal_id
    role_definition_name = "Storage Queue Data Contributor"
    scope                = var.storage_account_id
}

resource "azurerm_key_vault_access_policy" "notifier-access" {
    key_vault_id = var.key_vault_id
    tenant_id    = var.entra_tenant_id
    object_id    = azurerm_function_app_flex_consumption.notifier.identity[0].principal_id

    secret_permissions = [
        "Get", "List"
    ]
}