terraform {
  required_version = "0.13.2"

  backend "s3" {
    bucket = "sample-terraform"
    key    = "resources.shd.ecs.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  version = "3.6.0"
  region  = "ap-northeast-1"
}
