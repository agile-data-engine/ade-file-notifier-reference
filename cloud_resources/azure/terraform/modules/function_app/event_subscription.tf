resource "azurerm_role_assignment" "topic-queue-message-sender" {
    principal_id         = var.system_topic_principal_id
    role_definition_name = "Storage Queue Data Message Sender"
    scope                = azurerm_storage_account.notifier.id
}

resource "azurerm_eventgrid_system_topic_event_subscription" "topic-queue-message-sender" {
    depends_on = [azurerm_role_assignment.topic-queue-message-sender]
    name  = "evgs-${var.app}-${var.env}"
    system_topic = var.system_topic_name
    resource_group_name = var.system_topic_rg
    event_delivery_schema = "EventGridSchema"
    included_event_types = ["Microsoft.Storage.BlobCreated"]

    subject_filter {
        subject_begins_with = "/blobServices/default/containers/${var.source_data_container}/blobs/"
    }

    advanced_filter {
        number_greater_than {
            key = "data.ContentLength"
            value = 0
        }
    }

    storage_queue_endpoint {
        storage_account_id = azurerm_storage_account.notifier.id
        queue_name         = azurerm_storage_queue.blob-event-queue.name
    }

    delivery_identity {
        type = "SystemAssigned"
    }
}