locals {
    output_folder = "${path.root}/.output/${var.function_folder}"
}

resource "local_file" "host_json" {
    source = "${path.root}/../../../${var.function_folder}/azure/host.json"
    filename = "${local.output_folder}/host.json"
}

resource "local_file" "requirements_txt" {
    source = "${path.root}/../../../${var.function_folder}/azure/requirements.txt"
    filename = "${local.output_folder}/requirements.txt"
}

resource "local_file" "notify_function_json" {
    source = "${path.root}/../../../${var.function_folder}/azure/notify/function.json"
    filename = "${local.output_folder}/notify/function.json"
}

resource "local_file" "notify_notify_py" {
    source = "${path.root}/../../../${var.function_folder}/azure/notify/notify.py"
    filename = "${local.output_folder}/notify/notify.py"
}

resource "local_file" "queue_file_function_json" {
    source = "${path.root}/../../../${var.function_folder}/azure/queue_file/function.json"
    filename = "${local.output_folder}/queue_file/function.json"
}

resource "local_file" "queue_file_queue_file_py" {
    source = "${path.root}/../../../${var.function_folder}/azure/queue_file/queue_file.py"
    filename = "${local.output_folder}/queue_file/queue_file.py"
}

resource "local_file" "shared_azure_handler_py" {
    source = "${path.root}/../../../${var.function_folder}/azure/shared/azure_handler.py"
    filename = "${local.output_folder}/shared/azure_handler.py"
}

resource "local_file" "shared_notifier_common_py" {
    source = "${path.root}/../../../${var.function_folder}/common/notifier_common.py"
    filename = "${local.output_folder}/shared/notifier_common.py"
}