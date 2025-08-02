provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "fincore_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "fincore_sg" {
  name        = "fincore-sg"
  description = "Allow required ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH
  }

  ingress {
    from_port   = 3000
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Grafana, Prometheus, Node Exporter
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "fincore_ec2" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.fincore_key.key_name
  vpc_security_group_ids = [aws_security_group.fincore_sg.id]

  tags = {
    Name = "fincore-monitoring-instance"
  }
}
