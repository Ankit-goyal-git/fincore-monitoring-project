output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.fincore_ec2.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.fincore_ec2.id
}
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}
