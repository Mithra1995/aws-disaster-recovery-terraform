terraform {
  backend "s3" {
    bucket = "dr-demo-use1-east-37cfd18a"
    key    = "env:/terraform.tfstate"
    region = "us-east-1"
  }
}