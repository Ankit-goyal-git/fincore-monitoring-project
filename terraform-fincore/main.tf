provider "aws" {
  region = var.aws_region
}

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "FincoreVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "FincoreIGW"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "FincorePublicSubnet"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "FincorePublicRT"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Key Pair
resource "aws_key_pair" "fincore_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Security Group
resource "aws_security_group" "fincore_sg" {
  name        = "fincore-sg"
  description = "Allow required ports"
  vpc_id      = aws_vpc.main_vpc.id

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

  tags = {
    Name = "FincoreSG"
  }
}

# EC2 Instance in custom public subnet
resource "aws_instance" "fincore_ec2" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.fincore_key.key_name
  vpc_security_group_ids      = [aws_security_group.fincore_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable docker
              yum install -y docker git

              # Start Docker service
              systemctl enable docker
              systemctl start docker

              # Allow ec2-user to run Docker
              usermod -aG docker ec2-user
              chmod 666 /var/run/docker.sock

              cd /home/ec2-user
              git clone https://github.com/darpan-cloud/fincore-project.git
              chown -R ec2-user:ec2-user fincore-project
              cd fincore-project

              # Build and run Flask App
              docker build -t banking-app .
              docker run -d -p 5000:5000 banking-app

              # Start Prometheus
              docker run -d -p 9090:9090 \
                -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
                prom/prometheus

              # Start Node Exporter
              docker run -d -p 9100:9100 prom/node-exporter

              # Start Grafana with provisioning
              docker run -d -p 3000:3000 \
                -v $(pwd)/grafana/provisioning:/etc/grafana/provisioning \
                -v $(pwd)/grafana/dashboards:/var/lib/grafana/dashboards \
                -v $(pwd)/grafana/grafana.ini:/etc/grafana/grafana.ini \
                -v grafana-storage:/var/lib/grafana \
                grafana/grafana
              EOF

  tags = {
    Name = "fincore-monitoring-instance"
  }
}
