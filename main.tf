terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = [aws.global]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

/**
 * Assets & Cache S3 Bucket
 **/
module "assets" {
  source = "./modules/opennext-assets"

  prefix                   = "${var.prefix}-assets"
  assets_path              = "${local.opennext_abs_path}/assets"
  cache_path               = "${local.opennext_abs_path}/cache"
  server_function_role_arn = module.server_function.lambda_role.arn
}


/**
 * Next.js Server Function
 **/
module "server_function" {
  source = "./modules/opennext-lambda"

  prefix = "${var.prefix}-nextjs-server"

  function_name                  = local.server_options.function.function_name
  description                    = local.server_options.function.description
  handler                        = local.server_options.function.handler
  runtime                        = local.server_options.function.runtime
  architectures                  = local.server_options.function.architectures
  memory_size                    = local.server_options.function.memory_size
  timeout                        = local.server_options.function.timeout
  publish                        = local.server_options.function.publish
  dead_letter_config             = local.server_options.function.dead_letter_config
  reserved_concurrent_executions = local.server_options.function.reserved_concurrent_executions
  code_signing_config            = local.server_options.function.code_signing_config
  log_group                      = local.server_options.log_group


  source_dir = local.server_options.package.source_dir
  output_dir = local.server_options.package.output_dir

  vpc_id                       = local.server_options.networking.vpc_id
  subnet_ids                   = local.server_options.networking.subnet_ids
  security_group_ingress_rules = local.server_options.networking.security_group_ingress_rules
  security_group_egress_rules  = local.server_options.networking.security_group_egress_rules

  environment_variables = local.server_options.environment_variables
  iam_policy_statements = local.server_options.iam_policy_statements
}


/**
 * Image Optimization Function
 **/
module "image_optimization_function" {
  source = "./modules/opennext-lambda"

  prefix = "${var.prefix}-nextjs-image-optimization"

  function_name                  = local.image_optimization_options.function.function_name
  description                    = local.image_optimization_options.function.description
  handler                        = local.image_optimization_options.function.handler
  runtime                        = local.image_optimization_options.function.runtime
  architectures                  = local.image_optimization_options.function.architectures
  memory_size                    = local.image_optimization_options.function.memory_size
  timeout                        = local.image_optimization_options.function.timeout
  publish                        = local.image_optimization_options.function.publish
  dead_letter_config             = local.image_optimization_options.function.dead_letter_config
  reserved_concurrent_executions = local.image_optimization_options.function.reserved_concurrent_executions
  code_signing_config            = local.image_optimization_options.function.code_signing_config
  log_group                      = local.image_optimization_options.log_group

  source_dir = local.image_optimization_options.package.source_dir
  output_dir = local.image_optimization_options.package.output_dir

  vpc_id                       = local.image_optimization_options.networking.vpc_id
  subnet_ids                   = local.image_optimization_options.networking.subnet_ids
  security_group_ingress_rules = local.image_optimization_options.networking.security_group_ingress_rules
  security_group_egress_rules  = local.image_optimization_options.networking.security_group_egress_rules

  environment_variables = local.image_optimization_options.environment_variables
  iam_policy_statements = local.image_optimization_options.iam_policy_statements
}

/**
 * ISR Revalidation Function
 **/
module "revalidation_function" {
  source = "./modules/opennext-lambda"

  prefix = "${var.prefix}-nextjs-revalidation"

  function_name                  = local.revalidation_options.function.function_name
  description                    = local.revalidation_options.function.description
  handler                        = local.revalidation_options.function.handler
  runtime                        = local.revalidation_options.function.runtime
  architectures                  = local.revalidation_options.function.architectures
  memory_size                    = local.revalidation_options.function.memory_size
  timeout                        = local.revalidation_options.function.timeout
  publish                        = local.revalidation_options.function.publish
  dead_letter_config             = local.revalidation_options.function.dead_letter_config
  reserved_concurrent_executions = local.revalidation_options.function.reserved_concurrent_executions
  code_signing_config            = local.revalidation_options.function.code_signing_config
  log_group                      = local.revalidation_options.log_group

  source_dir = local.revalidation_options.package.source_dir
  output_dir = local.revalidation_options.package.output_dir

  vpc_id                       = local.revalidation_options.networking.vpc_id
  subnet_ids                   = local.revalidation_options.networking.subnet_ids
  security_group_ingress_rules = local.revalidation_options.networking.security_group_ingress_rules
  security_group_egress_rules  = local.revalidation_options.networking.security_group_egress_rules

  environment_variables = local.revalidation_options.environment_variables
  iam_policy_statements = local.revalidation_options.iam_policy_statements
}

/**
 * ISR Revalidation Queue
 **/
module "revalidation_queue" {
  source = "./modules/opennext-revalidation-queue"
  prefix = "${var.prefix}-revalidation-queue"

  aws_account_id            = data.aws_caller_identity.current.account_id
  revalidation_function_arn = module.revalidation_function.lambda_function.arn
}

/**
 * Revalidation DynamoDB Table
 **/
module "revalidation_table" {
  source = "./modules/opennext-dynamodb"
  prefix = "${var.prefix}-revalidation-table"

  name                   = local.revalidation_table_options.name
  billing_mode           = local.revalidation_table_options.billing_mode
  hash_key               = local.revalidation_table_options.hash_key
  range_key              = local.revalidation_table_options.range_key
  attribute              = local.revalidation_table_options.attribute
  global_secondary_index = local.revalidation_table_options.global_secondary_index
}

/**
 * Revalidation Insert Function
 **/
module "revalidation_insert_function" {
  count = local.create_revalidation_insert_stack ? 1 : 0

  source = "./modules/opennext-lambda"

  prefix = "${var.prefix}-nextjs-revalidation-insert"

  function_name                  = local.revalidation_insert_options.function.function_name
  description                    = local.revalidation_insert_options.function.description
  handler                        = local.revalidation_insert_options.function.handler
  runtime                        = local.revalidation_insert_options.function.runtime
  architectures                  = local.revalidation_insert_options.function.architectures
  memory_size                    = local.revalidation_insert_options.function.memory_size
  timeout                        = local.revalidation_insert_options.function.timeout
  publish                        = local.revalidation_insert_options.function.publish
  dead_letter_config             = local.revalidation_insert_options.function.dead_letter_config
  reserved_concurrent_executions = local.revalidation_insert_options.function.reserved_concurrent_executions
  code_signing_config            = local.revalidation_insert_options.function.code_signing_config
  log_group                      = local.revalidation_insert_options.log_group

  source_dir = local.revalidation_insert_options.package.source_dir
  output_dir = local.revalidation_insert_options.package.output_dir

  vpc_id                       = local.revalidation_insert_options.networking.vpc_id
  subnet_ids                   = local.revalidation_insert_options.networking.subnet_ids
  security_group_ingress_rules = local.revalidation_insert_options.networking.security_group_ingress_rules
  security_group_egress_rules  = local.revalidation_insert_options.networking.security_group_egress_rules

  environment_variables = local.revalidation_insert_options.environment_variables
  iam_policy_statements = local.revalidation_insert_options.iam_policy_statements
}

/**
 * Revalidation Insert Function rigger right after deployment
 **/

resource "aws_lambda_invocation" "revalidation_insert_trigger" {
  count         = local.create_revalidation_insert_stack ? 1 : 0
  function_name = module.revalidation_insert_function[0].lambda_function.function_name

  triggers = {
    deployed_at = timestamp()
  }

  input = jsonencode({
    "RequestType" = "Create"
  })

  depends_on = [module.revalidation_table, module.revalidation_insert_function]
}

/**
 * Warmer Function
 **/

module "warmer_function" {
  source = "./modules/opennext-lambda"

  prefix                            = "${var.prefix}-nextjs-warmer"
  create_eventbridge_scheduled_rule = true


  function_name                  = local.warmer_options.function.function_name
  description                    = local.warmer_options.function.description
  handler                        = local.warmer_options.function.handler
  runtime                        = local.warmer_options.function.runtime
  architectures                  = local.warmer_options.function.architectures
  memory_size                    = local.warmer_options.function.memory_size
  timeout                        = local.warmer_options.function.timeout
  publish                        = local.warmer_options.function.publish
  dead_letter_config             = local.warmer_options.function.dead_letter_config
  reserved_concurrent_executions = local.warmer_options.function.reserved_concurrent_executions
  code_signing_config            = local.warmer_options.function.code_signing_config
  log_group                      = local.warmer_options.log_group

  source_dir = local.warmer_options.package.source_dir
  output_dir = local.warmer_options.package.output_dir

  vpc_id                       = local.warmer_options.networking.vpc_id
  subnet_ids                   = local.warmer_options.networking.subnet_ids
  security_group_ingress_rules = local.warmer_options.networking.security_group_ingress_rules
  security_group_egress_rules  = local.warmer_options.networking.security_group_egress_rules

  environment_variables = local.warmer_options.environment_variables
  iam_policy_statements = local.warmer_options.iam_policy_statements
}

/**
 * Warmer Function trigger right after deployment
 **/

resource "aws_lambda_invocation" "warmer_deployment_trigger" {
  function_name = module.warmer_function.lambda_function.function_name

  triggers = {
    deployed_at = timestamp()
  }

  input = jsonencode({})

  depends_on = [module.warmer_function]
}

/**
 * CloudFront -> CloudWatch Logs
 **/
module "cloudfront_logs" {
  source = "./modules/cloudfront-logs"

  providers = {
    aws.global = aws.global
  }

  log_group_name  = "${var.prefix}-cloudfront-logs"
  log_bucket_name = "${var.prefix}-cloudfront-logs"
  retention       = 365
}

/**
 * Next.js CloudFront Distribution
 **/
module "cloudfront" {
  source = "./modules/opennext-cloudfront"
  prefix = "${var.prefix}-cloudfront"

  providers = {
    aws.global = aws.global
  }

  comment                       = local.cloudfront.comment
  logging_bucket_domain_name    = module.cloudfront_logs.logs_s3_bucket.bucket_regional_domain_name
  assets_origin_access_identity = module.assets.cloudfront_origin_access_identity.cloudfront_access_identity_path

  origins = {
    assets_bucket               = module.assets.assets_bucket.bucket_regional_domain_name
    server_function             = "${module.server_function.lambda_function_url.url_id}.lambda-url.${data.aws_region.current.name}.on.aws"
    image_optimization_function = "${module.image_optimization_function.lambda_function_url.url_id}.lambda-url.${data.aws_region.current.name}.on.aws"
  }

  aliases               = local.cloudfront.aliases
  acm_certificate_arn   = local.cloudfront.acm_certificate_arn
  assets_paths          = local.cloudfront.assets_paths
  custom_headers        = local.cloudfront.custom_headers
  geo_restriction       = local.cloudfront.geo_restriction
  cors                  = local.cloudfront.cors
  hsts                  = local.cloudfront.hsts
  cache_policy          = local.cloudfront.cache_policy
  remove_headers_config = local.cloudfront.remove_headers_config

  custom_waf                = local.cloudfront.custom_waf
  waf_logging_configuration = local.cloudfront.waf_logging_configuration

  custom_host_header_function = local.cloudfront.custom_host_header_function
}
