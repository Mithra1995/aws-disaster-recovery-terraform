terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2" # patch-upgrade friendly
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

