output "cloud_vpc_id" {
  description = "VPC Id"
  value = aws_vpc.Cloud-VPC.id
}

output "cloud_public_subnets" {
  description = "Will be used by the webserver module to set subnet_ids"
  value = [
    aws_subnet.cloudPublicSubnet1,
    aws_subnet.cloudPublicSubnet2
  ]
}

output "cloud_private_subnets" {
  description = "Will be used by the RDS Module to set subnet_ids"
  value = [
    aws_subnet.cloudPrivateSubnet1,
    aws_subnet.cloudPrivateSubnet2
  ]
}