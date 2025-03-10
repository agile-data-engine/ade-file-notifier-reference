module "app_service_plan" {
  source = "./modules/app_service_plan"
  app = var.app
  env = var.env
  location = var.location
  rg = var.rg
  sku = "EP1"
  worker_count = 1
}

module "network" {
  source = "./modules/network"
  app = var.app
  env = var.env
  location = var.location
  rg = var.rg
  subnet_cidr_range = var.subnet_cidr_range
  vnet_cidr_range = var.vnet_cidr_range
}

module "secrets" {
  source = "./modules/secrets"
  depends_on = [module.network]
  allowed_ips = var.allowed_ips
  allowed_subnet_ids = [module.network.subnet_id]
  app = var.app
  entra_tenant_id = var.entra_tenant_id
  env = var.env
  external_api_key = var.external_api_key
  external_api_key_secret = var.external_api_key_secret
  location = var.location
  notify_api_key = var.notify_api_key
  notify_api_key_secret = var.notify_api_key_secret
  rg = var.rg
  security_group_id = var.security_group_id
}

module "storage_account" {
  source = "./modules/storage_account"
  depends_on = [module.network]
  allowed_ips = var.allowed_ips
  allowed_subnet_ids = [module.network.subnet_id]
  app = var.app
  blob_event_queue = "blob-event-queue"
  container_name = "notifier"
  env = var.env
  location = var.location
  notify_queue = "notify-queue"
  rg = var.rg
  security_group_id = var.security_group_id
}

module "event_subscription" {
  source = "./modules/event_subscription"
  depends_on = [module.storage_account]
  app = var.app
  blob_event_queue_name = module.storage_account.blob_event_queue_name
  env = var.env
  queue_storage_account_id = module.storage_account.id
  source_data_container = var.source_data_container
  system_topic_name = var.system_topic_name
  system_topic_principal_id = var.system_topic_principal_id
  system_topic_rg = var.system_topic_rg
}

module "function_app" {
  source = "./modules/function_app"
  depends_on = [module.app_service_plan, module.network, module.secrets, module.storage_account]
  allowed_ips = var.allowed_ips
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
  notify_queue = module.storage_account.notify_queue_name
  notify_api_base_url = var.notify_api_base_url
  rg = var.rg
  security_group_id = var.security_group_id
  subnet_id = module.network.subnet_id
  storage_account_id = module.storage_account.id
  storage_account_name = module.storage_account.name
  storage_primary_blob_endpoint = module.storage_account.primary_blob_endpoint
  storage_primary_queue_endpoint = module.storage_account.primary_queue_endpoint
  system_topic_name = var.system_topic_name
  system_topic_principal_id = var.system_topic_principal_id
  system_topic_rg = var.system_topic_rg
}