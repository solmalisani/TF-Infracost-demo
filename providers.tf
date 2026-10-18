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

  # assume_role {
  #   role_arn = "arn:aws:iam::654740196132:role/github"
  # }

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
