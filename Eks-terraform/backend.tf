terraform {
  backend "s3" {
    bucket = var.bucket # Replace with your actual S3 bucket name
    key    = "Jenkins/terraform.tfstate"
    region = var.aws_region
  }
}

