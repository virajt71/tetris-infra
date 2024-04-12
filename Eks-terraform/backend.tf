terraform {
  backend "s3" {
    bucket = "argo-cd-backend-tetris"
    key    = "eks/terraform.tfstate"
    region = "us-east-2"
  }
}
