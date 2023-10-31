/**
 * Common Variables
 **/
variable "prefix" {
  type        = string
  description = "Prefix for created resource IDs"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to all created resources"
  default     = {}
}

/**
  * DynamoDB Table Variables
  **/

variable "name" {
  type        = string
  description = "The name of the DynamoDB table"
}

variable "billing_mode" {
  type        = string
  description = "Controls how you are charged for read and write throughput and how you manage capacity. The valid values are PROVISIONED and PAY_PER_REQUEST."
  default     = "PAY_PER_REQUEST"
}

variable "point_in_time_recovery" {
  type        = bool
  description = "Point-in-time recovery (PITR) provides continuous backups of your DynamoDB table data. "
  default     = true
}

variable "hash_key" {
  type        = string
  description = "The attribute to use as the hash (partition) key"
}

variable "range_key" {
  type        = string
  description = "The attribute to use as the range (sort) key"
}

variable "attribute" {
  type = list(object({
    name = string
    type = string
  }))
  description = "The attributes to create on the DynamoDB table"
  default     = []
}

variable "global_secondary_index" {
  type = object({
    name               = string
    hash_key           = string
    range_key          = string
    write_capacity     = optional(number)
    read_capacity      = optional(number)
    projection_type    = string
    non_key_attributes = optional(list(string))
  })
  description = "Global secondary indexes to be created on the DynamoDB table"
  default     = null
}
