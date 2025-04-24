
terraform {
  backend "s3" {
    bucket         = "nebula-terraform-state123"
    key            = "terraform.tfstate"
    region         = "eu-west-1"  # Use primary region for state management
    dynamodb_table = "nebula-terraform-locks"
    encrypt        = true
  }
}

