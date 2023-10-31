resource "aws_dynamodb_table" "table" {
  name         = var.name != null ? var.name : var.prefix
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  dynamic "attribute" {
    for_each = var.attribute

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  global_secondary_index {
    name               = var.global_secondary_index.name
    hash_key           = var.global_secondary_index.hash_key
    range_key          = var.global_secondary_index.range_key
    write_capacity     = var.global_secondary_index.write_capacity
    read_capacity      = var.global_secondary_index.read_capacity
    projection_type    = var.global_secondary_index.projection_type
    non_key_attributes = var.global_secondary_index.non_key_attributes
  }
}
