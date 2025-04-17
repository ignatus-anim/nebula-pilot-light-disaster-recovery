terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.dr_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "${var.environment_name}-dr"
      Terraform   = "true"
      DR          = "true"
    }
  }
}

# Provider configuration for Primary region
provider "aws" {
  alias  = "primary_region"
  region = var.primary_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment_name
      Terraform   = "true"
    }
  }
}
