locals {
  # List all YAML files in the config/ folder
  datasource_files = fileset("${path.root}/../../../config/", "*.yaml")

  # Parse each YAML file
  parsed_configs = {
    for file in local.datasource_files :
      file => yamldecode(file("${path.root}/../../../config/${file}"))
  }

  # Construct list of source systems with cron schedules
  source_system_schedules = flatten([
    for config in local.parsed_configs : [
      for source in try(config.source_systems, []) :
        {
          ade_source_system = source.ade_source_system
          ade_source_entity = ""
          cron_schedule = source.cron_schedule
        }
        if length(try(source.cron_schedule, "")) > 0
    ]
  ])

  # Construct list of source entities with cron schedules
  source_entity_schedules = flatten([
    for config in local.parsed_configs : [
      for source in try(config.source_systems, []) : [
        for entity in try(source.entities, []) :
          {
            ade_source_system = source.ade_source_system
            ade_source_entity = entity.ade_source_entity
            cron_schedule = entity.cron_schedule
          }
          if length(try(entity.cron_schedule, "")) > 0
      ]
    ]
  ])

  # Combined list
  schedules = setunion(local.source_system_schedules, local.source_entity_schedules)

  # Distinct cron schedules
  distinct_cron_schedules = distinct([
    for schedule in local.schedules :
      schedule.cron_schedule
  ]) 

  # Triggers by cron_schedule
  triggers_by_cron = [
    for schedule in local.distinct_cron_schedules :
    {
      cron_schedule = schedule
      triggers = [
        for item in local.schedules :
          [      
            item.ade_source_system,
            item.ade_source_entity
          ]
          if item.cron_schedule == schedule
      ]
    }
  ]
}

output "test" {
  value = local.triggers_by_cron
}

module "timer_trigger_function" {
  source = "../timer_trigger_function"
  function_output_folder = local.output_folder
  for_each = {
    for cron in local.triggers_by_cron : cron.cron_schedule => cron
  }
  function_name = "timer_${replace(replace(replace(each.key, " ", "_"), "/", ""), "*", "a")}" # Should probably use something else than cron as function name
  cron_expression = each.key
  trigger_message = jsonencode({calls = each.value.triggers})
}