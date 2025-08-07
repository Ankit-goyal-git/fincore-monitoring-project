terraform {
  backend "s3" {
    bucket = "fincore-terraform-state"   # your actual bucket name
    key    = "terraform/infra.tfstate"   # path inside S3 (can be any string)
    region = "ap-south-1"                # your region
    encrypt = true                       # encrypts state file at rest
  }
}
