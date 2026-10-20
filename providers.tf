terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "dd-demo-sm"
    key    = "terraform/state"
    region = "eu-north-1"
  }

}

provider "aws" {
  region = var.region


  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Service     = "datadog-demo"
    }
  }
}
