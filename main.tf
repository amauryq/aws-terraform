# Main

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# Modules

module "vpc" {
  source = "./modules/vpc"
  
}

module "transfer_family" {
  source = "./modules/transfer-family"
}
