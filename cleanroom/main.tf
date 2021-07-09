terraform {
  backend "s3" {
    bucket         = "cleanroom-terraform-state"
    key            = "cleanroom/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "cleanroom-terraform-state-lock"
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}