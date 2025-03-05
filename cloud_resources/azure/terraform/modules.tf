module "app_service_plan" {
  source = "./modules/app_service_plan"
  app = var.app
  env = var.env
  location = var.location
  rg = var.rg
}

module "network" {
  source = "./modules/network"
  app = var.app
  env = var.env
  location = var.location
  rg = var.rg
  subnet_cidr_range =  var.subnet_cidr_range
  vnet_cidr_range =  var.vnet_cidr_range
}

module "secrets" {
  source = "./modules/secrets"
  depends_on = [module.network]
  allowed_ips = var.allowed_ips
  app = var.app
  env = var.env
  location = var.location
  rg = var.rg
  security_group_id = var.security_group_id
  subnet_id = module.network.subnet_id
  notify_api_key = var.notify_api_key
  notify_api_key_secret = var.notify_api_key_secret
  external_api_key = var.external_api_key
  external_api_key_secret = var.external_api_key_secret
}

module "function_app" {
  source = "./modules/function_app"
  depends_on = [module.app_service_plan, module.network, module.secrets]
  allowed_ips = var.allowed_ips
  app = var.app
  asp_id = module.app_service_plan.asp_id
  blob_event_queue = "blob-event-queue"
  config_folder = "config"
  config_prefix = "data-sources/"
  container_name = "notifier"
  env = var.env
  external_api_base_url = var.external_api_base_url
  function_folder = "functions"
  key_vault_name = module.secrets.key_vault_name
  location = var.location
  notify_queue = "notify-queue"
  notify_api_base_url = var.notify_api_base_url
  rg = var.rg
  security_group_id = var.security_group_id
  source_data_container = var.source_data_container
  subnet_id = module.network.subnet_id
  system_topic_name = var.system_topic_name
  system_topic_rg = var.system_topic_rg
}