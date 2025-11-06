module "service_account" {
  source  = "./modules/service_account"
  project = var.project
  app     = var.app
  env     = var.env
  region  = var.region
}

module "secrets" {
  source                   = "./modules/secrets"
  env                      = var.env
  region                   = var.region
  notifier_service_account = module.service_account.notifier_service_account
}

module "event_queues" {
  source                   = "./modules/event_queues"
  app                      = var.app
  env                      = var.env
  region                   = var.region
  source_data_bucket       = var.source_data_bucket
  notifier_service_account = module.service_account.notifier_service_account
}

module "file_event_processor" {
  source                           = "./modules/file_event_processor"
  app                              = var.app
  env                              = var.env
  region                           = var.region
  notifier_bucket_name             = "${var.app}-${var.env}"
  source_data_bucket               = var.source_data_bucket
  function_folder                  = "../../../functions"
  config_file_path                 = var.config_file_path
  notifier_service_account         = module.service_account.notifier_service_account
  file_url_prefix                  = "gs://"
  config_prefix                    = "data-sources/"
  max_instances_preprocessor       = 5
  max_instance_request_concurrency = 20
  available_cpu                    = "1"
  file_event_pubsub_topic_id       = module.event_queues.file_event_pubsub_topic_id
  notifier_pubsub_topic_id         = module.event_queues.notifier_pubsub_topic_id
}

/*
Optional network module, if it needs to be created. 
The assumption is that network setup already exists.
Note that variable: var.vpc_connector_name needs to be properly set up,
if network is done from this module.
module "network" {
  source = "./modules/network"
  app                = var.app
  env                = var.env
  region             = var.region
  cidr_range         = var.cidr_range
  nat_ip_allocate_option = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  max_instances      = 3
  min_instances      = 2
 }
 */

module "file_notifier" {
  source                           = "./modules/file_notifier"
  project                          = var.project
  app                              = var.app
  env                              = var.env
  region                           = var.region
  notifier_service_account         = module.service_account.notifier_service_account
  notifier_bucket                  = module.file_event_processor.notifier_bucket_name
  function_source_code_object      = module.file_event_processor.notifier_bucket_source_code_object
  file_url_prefix                  = "gs://"
  config_prefix                    = "data-sources/"
  function_timeout                 = 540
  function_memory                  = "4G"
  max_instances                    = 10
  max_instance_request_concurrency = 1
  available_cpu                    = "2"
  notify_api_secret_id             = module.secrets.notify_api_secret_id
  external_api_secret_id           = module.secrets.external_api_secret_id
  vpc_connector_name               = var.vpc_connector_name
  notifier_pubsub_topic_id         = module.event_queues.notifier_pubsub_topic_id
  ingress_settings                 = "ALLOW_ALL"
  timezone                         = "UTC"
}

module "notifier_scheduler" {
  source                           = "./modules/notifier_scheduler"
  project                          = var.project
  app                              = var.app
  env                              = var.env
  region                           = var.region
  config_file_path                 = var.config_file_path
  notifier_pubsub_topic_id         = module.event_queues.notifier_pubsub_topic_id
  scheduler_timezone               = "UTC"
}

# Optional module, if one wants to execute notifier from BigQuery with remote function.
module "bigquery_remote_function" {
  source                 = "./modules/bigquery_remote_function"
  project                = var.project
  app                    = var.app
  env                    = var.env
  region                 = var.region
  notifier_function_name = module.file_notifier.notifier_function_name_http
  notifier_function_url  = module.file_notifier.notifier_function_url_http
}