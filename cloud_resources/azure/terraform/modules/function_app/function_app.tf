data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "notifier" {
    name                = var.key_vault_name
    resource_group_name = var.rg
}

module "function_files" {
    source = "../function_files"
    function_folder = var.function_folder
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
    storage_account_name = azurerm_storage_account.notifier.name
    storage_uses_managed_identity = true
    virtual_network_subnet_id = var.subnet_id
    functions_extension_version = "~4"
    https_only = true
    zip_deploy_file = data.archive_file.function_archive.output_path
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
    }
    app_settings = {
        AzureWebJobsDisableHomepage = true
        AzureWebJobsStorage__credential = "managedidentity"
        AzureWebJobsStorage__blobServiceUri = azurerm_storage_account.notifier.primary_blob_endpoint
        AzureWebJobsStorage__queueServiceUri = azurerm_storage_account.notifier.primary_queue_endpoint
        AzureWebJobsFeatureFlags = "EnableWorkerIndexing"
        ENABLE_ORYX_BUILD = true
        SCM_DO_BUILD_DURING_DEPLOYMENT = true
        blob_event_queue = var.blob_event_queue
        notify_queue = var.notify_queue
        container_name = var.container_name
        config_prefix = var.config_prefix
        notify_api_base_url = var.notify_api_base_url
        external_api_base_url = var.external_api_base_url
        notify_api_key = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.notifier.vault_uri}/secrets/notify-api-key)"
        notify_api_key_secret = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.notifier.vault_uri}/secrets/notify-api-key-secret)"
        external_api_key = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.notifier.vault_uri}/secrets/external-api-key)"
        external_api_key_secret = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.notifier.vault_uri}/secrets/external-api-key-secret)"
    }
}

resource "azurerm_role_assignment" "notifier-storage-contributor" {
    principal_id         = azurerm_linux_function_app.notifier.identity[0].principal_id
    role_definition_name = "Storage Account Contributor"
    scope                = azurerm_storage_account.notifier.id
}

resource "azurerm_role_assignment" "notifier-blob-owner" {
    principal_id         = azurerm_linux_function_app.notifier.identity[0].principal_id
    role_definition_name = "Storage Blob Data Owner"
    scope                = azurerm_storage_account.notifier.id
}

resource "azurerm_role_assignment" "notifier-queue-contributor" {
    principal_id         = azurerm_linux_function_app.notifier.identity[0].principal_id
    role_definition_name = "Storage Queue Data Contributor"
    scope                = azurerm_storage_account.notifier.id
}

resource "azurerm_key_vault_access_policy" "notifier-access" {
    key_vault_id = data.azurerm_key_vault.notifier.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_linux_function_app.notifier.identity[0].principal_id

    secret_permissions = [
        "Get", "List"
    ]
}