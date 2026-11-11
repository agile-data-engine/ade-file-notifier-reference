resource "azurerm_storage_blob" "config-files" {
  for_each               = fileset("${path.root}/../../../${var.config_folder}/", "{*.yaml,*.yml}")
  name                   = "${var.config_prefix}${each.key}"
  storage_container_id   = var.storage_container_id
  type                   = "Block"
  source                 = "${path.root}/../../../${var.config_folder}/${each.key}"
  content_md5            = filemd5("${path.root}/../../../${var.config_folder}/${each.key}")
}