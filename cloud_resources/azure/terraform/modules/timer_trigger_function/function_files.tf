resource "local_file" "timer_trigger_py" {
  filename = "${var.function_output_folder}/${var.function_name}/timer_trigger.py"
  content  = <<-EOT
    import logging
    import azure.functions as func
    import os
    import json
    import base64
    from azure.storage.queue import QueueClient
    from azure.identity import DefaultAzureCredential

    def main(myTimer: func.TimerRequest) -> None:
        queue_url = os.getenv('AzureWebJobsStorage__queueServiceUri')
        queue_name = os.getenv('notify_queue')
        message_data = ${var.trigger_message}
        message_json = json.dumps(message_data)
        message_base64 = base64.b64encode(message_json.encode('utf-8')).decode('utf-8')

        try:
            # Using managed identity
            credential = DefaultAzureCredential()
            queue_client = QueueClient(queue_url, queue_name=queue_name, credential=credential)

            queue_client.send_message(message_base64)
            logging.info(f"Message added to queue: {message_json}")

        except Exception as e:
            logging.error(f"Error adding message to queue: {e}")
    EOT
}

resource "local_file" "function_json" {
  filename = "${var.function_output_folder}/${var.function_name}/function.json"
  content  = <<-EOT
    {
      "scriptFile": "timer_trigger.py",
      "entryPoint": "main",
      "bindings": [
          {
              "scriptFile": "timer_trigger.py",
              "schedule": "${var.cron_expression}",
              "name": "myTimer",
              "type": "timerTrigger",
              "direction": "in"
          }
      ]
    }
    EOT
}