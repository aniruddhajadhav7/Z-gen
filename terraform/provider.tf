terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state (recommended for teams)
  # backend "s3" {
  #   bucket         = "z-gen-terraform-state"
  #   key            = "eks/terraform.tfstate"
  #   region         = "eu-north-1"
  #   dynamodb_table = "z-gen-tf-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Z-gen"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
