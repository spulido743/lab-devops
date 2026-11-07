terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }

  backend "s3" {
    bucket       = "lab-devops-964215584742"
    key          = "tfstate/lab-devops.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
