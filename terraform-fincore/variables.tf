variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  default = "ami-0d0ad8bb301edb745" # Amazon Linux 2023
}

variable "key_name" {
  default = "fincore-key"
}

variable "public_key_path" {
  default = "/home/ec2-user/.ssh/fincore-key.pub" 
}

