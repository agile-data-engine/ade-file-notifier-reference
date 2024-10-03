module "service_account" {
  source = "./modules/service_account"
  project            = var.project
  app                = var.app
  env                = var.env
  region             = var.region
}

module "file_event_processor" {
  source = "./modules/file_event_processor"
  app                = var.app
  env                = var.env
  region             = var.region
  source_data_bucket = var.source_data_bucket
  function_folder    = "functions"
  notifier_service_account = module.service_account.notifier_service_account
  file_url_prefix    = "gs://"
  config_prefix      = "data-sources/"
  max_instances_preprocessor = 5
  max_instance_request_concurrency = 20
  available_cpu      = "1"
}

module "file_notifier" {
  source = "./modules/file_notifier"
  project            = var.project
  app                = var.app
  env                = var.env
  region             = var.region
  notifier_service_account = module.service_account.notifier_service_account
  notifier_bucket    = module.file_event_processor.notifier_bucket_name
  function_source_code_object = module.file_event_processor.notifier_bucket_source_code_object
  file_url_prefix    = "gs://"
  config_prefix      = "data-sources/"
  function_timeout   = 540
  function_memory    = "4G"
  max_instances      = 10
  max_instance_request_concurrency = 1
  available_cpu      = "2"
  notify_api_secret_id  = "notify_api_dev"
  vpc_connector_name    = "vpcac-adenf-dev"
  schedule           = "0 */2 * * *"
}

resource "google_secret_manager_secret_iam_binding" "notify_api_access" {
  secret_id   = "notify_api_dev"
  role = "roles/secretmanager.secretAccessor"
  members = ["serviceAccount:${module.service_account.notifier_service_account}"]
}

/*module "network" {
   source = "./modules/network"
   app                = var.app
   env                = var.env
   region             = var.region
   cidr_range         = var.cidr_range
 }*/