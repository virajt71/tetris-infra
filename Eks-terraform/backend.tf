terraform {
  backend "s3" {
    bucket = "argo-cd-deployment" # Replace with your actual S3 bucket name
    key    = "eks/terraform.tfstate"
    region = "eu-central-1"
  }
}
