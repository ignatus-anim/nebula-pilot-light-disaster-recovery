terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.primary_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment_name
      Terraform   = "true"
    }
  }
}

# Provider configuration for DR region
provider "aws" {
  alias  = "dr_region"
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
