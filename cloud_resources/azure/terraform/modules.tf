module "app_service_plan" {
  source = "./modules/app_service_plan"
  app = var.app
  env = var.env
  location = var.location
  rg = var.rg
  sku = "FC1" # Use "EP1" for Elastic Premium plan
  tags = var.tags
  # worker_count = 1 # Configure if using Elastic Premium plan
}

module "log_analytics" {
  source = "./modules/log_analytics"
  app = var.app
  env = var.env
  location = var.location
  rg = var.rg
  tags = var.tags
}

module "network" {
  source = "./modules/network"
  app = var.app
  env = var.env
  location = var.location
  rg = var.rg
  service_delegation_name = "Microsoft.App/environments" # Use "Microsoft.Web/serverFarms" with Elastic Premium plan
  subnet_cidr_range = var.subnet_cidr_range
  tags = var.tags
  vnet_cidr_range = var.vnet_cidr_range
}

module "secrets" {
  source = "./modules/secrets"
  allowed_cidr_ranges = var.allowed_cidr_ranges
  allowed_subnet_ids = setunion([module.network.subnet_id], var.allowed_subnet_ids)
  app = var.app
  entra_tenant_id = var.entra_tenant_id
  env = var.env
  external_api_key = var.external_api_key
  external_api_key_secret = var.external_api_key_secret
  location = var.location
  notify_api_key = var.notify_api_key
  notify_api_key_secret = var.notify_api_key_secret
  rg = var.rg
  security_group_ids = var.security_group_ids
  tags = var.tags
}

module "storage_account" {
  source = "./modules/storage_account"
  allowed_cidr_ranges = var.allowed_cidr_ranges
  allowed_subnet_ids = setunion([module.network.subnet_id], var.allowed_subnet_ids)
  app = var.app
  blob_event_queue = "blob-event-queue"
  container_name = "notifier"
  env = var.env
  location = var.location
  name = var.storage_account_name
  notify_queue = "notify-queue"
  rg = var.rg
  security_group_ids = var.security_group_ids
  tags = var.tags
}

module "event_subscription" {
  source = "./modules/event_subscription"
  app = var.app
  blob_event_queue_name = module.storage_account.blob_event_queue_name
  env = var.env
  queue_storage_account_id = module.storage_account.id
  source_data_container = var.source_data_container
  system_topic_name = var.system_topic_name
  system_topic_principal_id = var.system_topic_principal_id
  system_topic_rg = var.system_topic_rg
}

# Azure Functions Flex Consumption plan used by default
module "function_app" {
  source = "./modules/function_app_flex"
  allowed_cidr_ranges = var.allowed_cidr_ranges
  allowed_subnet_ids = var.allowed_subnet_ids
  app = var.app
  asp_id = module.app_service_plan.asp_id
  blob_event_queue = module.storage_account.blob_event_queue_name
  config_folder = "config"
  config_prefix = "data-sources/"
  container_name = module.storage_account.container_name
  entra_tenant_id = var.entra_tenant_id
  env = var.env
  external_api_base_url = var.external_api_base_url
  function_folder = "functions"
  key_vault_id = module.secrets.key_vault_id
  key_vault_name = module.secrets.key_vault_name
  key_vault_uri = module.secrets.key_vault_uri
  location = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
  notify_queue = module.storage_account.notify_queue_name
  notify_api_base_url = var.notify_api_base_url
  rg = var.rg
  subnet_id = module.network.subnet_id
  storage_account_id = module.storage_account.id
  storage_account_name = module.storage_account.name
  storage_primary_blob_endpoint = module.storage_account.primary_blob_endpoint
  storage_primary_queue_endpoint = module.storage_account.primary_queue_endpoint
  storage_primary_table_endpoint = module.storage_account.primary_table_endpoint
  tags = var.tags
}

/*
# Use this instead if opting for Azure Functions Elastic Premium plan
module "function_app" {
  source = "./modules/function_app_premium"
  allowed_cidr_ranges = var.allowed_cidr_ranges
  allowed_subnet_ids = setunion([module.network.subnet_id], var.allowed_subnet_ids)
  app = var.app
  asp_id = module.app_service_plan.asp_id
  blob_event_queue = module.storage_account.blob_event_queue_name
  config_folder = "config"
  config_prefix = "data-sources/"
  container_name = module.storage_account.container_name
  entra_tenant_id = var.entra_tenant_id
  env = var.env
  external_api_base_url = var.external_api_base_url
  function_folder = "functions"
  key_vault_id = module.secrets.key_vault_id
  key_vault_name = module.secrets.key_vault_name
  key_vault_uri = module.secrets.key_vault_uri
  location = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
  notify_queue = module.storage_account.notify_queue_name
  notify_api_base_url = var.notify_api_base_url
  rg = var.rg
  subnet_id = module.network.subnet_id
  storage_account_id = module.storage_account.id
  storage_account_name = module.storage_account.name
  storage_primary_blob_endpoint = module.storage_account.primary_blob_endpoint
  storage_primary_queue_endpoint = module.storage_account.primary_queue_endpoint
  tags = var.tags
}
*/