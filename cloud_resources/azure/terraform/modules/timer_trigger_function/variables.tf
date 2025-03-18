variable "function_output_folder" {
  type = string
  description = "Local output folder"
}

variable "function_name" {
  type = string
  description = "Name of timer trigger function"
}

variable "cron_expression" {
  type = string
  description = "Function cron schedule"
}

variable "trigger_message" {
  type = string
  description = "Trigger message defining which sources to notify"
}