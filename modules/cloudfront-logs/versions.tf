terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = [aws.global]
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}
