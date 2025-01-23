locals {
  # List all YAML files in the config/ folder
  datasource_files = fileset("${path.root}/../../../config/", "*.yaml")

  # Parse each YAML file
  parsed_configs = {
    for file in local.datasource_files :
      file => yamldecode(file("${path.root}/../../../config/${file}"))
  }

  # Construct list of schedules
  schedules = flatten([
    for config in local.parsed_configs : [
      for schedule in try(config.schedules, []) :
        {
          schedule_id = schedule.schedule_id
          name = schedule.name
          cron = schedule.cron
        }
        if try(schedule.schedule_id, null) != null
        && length(try(schedule.name, "")) > 0
        && length(try(schedule.cron, "")) > 0
    ]
  ])

  # Construct list of source systems assigned schedules
  source_system_schedules = flatten([
    for config in local.parsed_configs : [
      for source in try(config.source_systems, []) :
        {
          ade_source_system = source.ade_source_system
          ade_source_entity = ""
          schedule_id = source.schedule_id
        }
        if try(source.schedule_id, null) != null
    ]
  ])

  # Construct list of source entities with assigned schedules
  source_entity_schedules = flatten([
    for config in local.parsed_configs : [
      for source in try(config.source_systems, []) : [
        for entity in try(source.entities, []) :
          {
            ade_source_system = source.ade_source_system
            ade_source_entity = entity.ade_source_entity
            schedule_id = entity.schedule_id
          }
          if try(entity.schedule_id, null) != null
      ]
    ]
  ])

  # Combined list
  assigned_schedules = setunion(local.source_system_schedules, local.source_entity_schedules)

  # Triggers
  triggers = [
    for schedule in local.schedules :
    {
      schedule_id = schedule.schedule_id
      name = schedule.name
      cron = schedule.cron
      triggers = [
        for item in local.assigned_schedules :
          [      
            item.ade_source_system,
            item.ade_source_entity
          ]
          if item.schedule_id == schedule.schedule_id
      ]
    }
  ]
}

module "timer_trigger_function" {
  source = "../timer_trigger_function"
  function_output_folder = local.output_folder
  for_each = {
    for index, trigger in local.triggers :
      trigger.name => trigger
  }
  function_name = "timer_${each.value.name}"
  cron_expression = each.value.cron
  trigger_message = jsonencode({calls = each.value.triggers})
}