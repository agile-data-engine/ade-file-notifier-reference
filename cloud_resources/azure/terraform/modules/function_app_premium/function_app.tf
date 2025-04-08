module "function_files" {
    source = "../function_files"
    config_folder = var.config_folder
    config_prefix = var.config_prefix
    function_folder = var.function_folder
    storage_account_name = var.storage_account_name
    storage_container_name = var.container_name
}

data "archive_file" "function_archive" {
  depends_on = [module.function_files]
  type        = "zip"
  output_path = "${path.root}/.output/app_${timestamp()}.zip" 
  source_dir = module.function_files.function_output_folder
}

resource "azurerm_linux_function_app" "notifier" {
    name = "func-${var.app}-${var.env}"
    location = var.location
    resource_group_name = var.rg
    service_plan_id = var.asp_id
    storage_account_name = var.storage_account_name
    storage_uses_managed_identity = true
    virtual_network_subnet_id = var.subnet_id
    functions_extension_version = "~4"
    https_only = true
    zip_deploy_file = data.archive_file.function_archive.output_path
    tags = var.tags
    identity {
        type = "SystemAssigned"
    }
    site_config {
        application_insights_connection_string = azurerm_application_insights.notifier.connection_string
        application_insights_key = azurerm_application_insights.notifier.instrumentation_key
        vnet_route_all_enabled = true
        application_stack {
            python_version = "3.11"
        }
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
        AzureWebJobsStorage__credential = "managedidentity"
        AzureWebJobsStorage__blobServiceUri = var.storage_primary_blob_endpoint
        AzureWebJobsStorage__queueServiceUri = var.storage_primary_queue_endpoint
        AzureWebJobsFeatureFlags = "EnableWorkerIndexing"
        ENABLE_ORYX_BUILD = true
        SCM_DO_BUILD_DURING_DEPLOYMENT = true
        blob_event_queue = var.blob_event_queue
        notify_queue = var.notify_queue
        container_name = var.container_name
        config_prefix = var.config_prefix
        notify_api_base_url = var.notify_api_base_url
        external_api_base_url = var.external_api_base_url
        key_vault_uri = var.key_vault_uri
    }
}

resource "azurerm_role_assignment" "notifier-storage-contributor" {
    principal_id         = azurerm_linux_function_app.notifier.identity[0].principal_id
    role_definition_name = "Storage Account Contributor"
    scope                = var.storage_account_id
}

resource "azurerm_role_assignment" "notifier-blob-owner" {
    principal_id         = azurerm_linux_function_app.notifier.identity[0].principal_id
    role_definition_name = "Storage Blob Data Owner"
    scope                = var.storage_account_id
}

resource "azurerm_role_assignment" "notifier-queue-contributor" {
    principal_id         = azurerm_linux_function_app.notifier.identity[0].principal_id
    role_definition_name = "Storage Queue Data Contributor"
    scope                = var.storage_account_id
}

resource "azurerm_key_vault_access_policy" "notifier-access" {
    key_vault_id = var.key_vault_id
    tenant_id    = var.entra_tenant_id
    object_id    = azurerm_linux_function_app.notifier.identity[0].principal_id

    secret_permissions = [
        "Get", "List"
    ]
}