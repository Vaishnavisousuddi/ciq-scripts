terraform {
  backend "s3" {
    bucket         = "ciq-terraform-state-804540873012"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "ciq-terraform-locks"
    encrypt        = true
  }
}