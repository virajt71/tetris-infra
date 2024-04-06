terraform {
  backend "s3" {
    bucket = "argo-cd-backend-tetris" # Replace with your actual S3 bucket name
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
