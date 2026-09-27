terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: uncomment and configure if you want remote state
  # (recommended once you wire this into CI/CD, so state isn't only local)
  #
  # backend "s3" {
  #   bucket = "nca-terraform-state-<your-suffix>"
  #   key    = "nca/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}

provider "aws" {
  region = var.aws_region
}
