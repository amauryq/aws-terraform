output "vpc_id" {
  value = aws_vpc.custom_vpc_1.id
}

output "ig_id" {
  value = aws_internet_gateway.custom_ig_1.id
}

output "rt_id" {
  value = aws_vpc.custom_vpc_1.default_route_table_id
}

output "sn_ids" {
  value = [
    aws_subnet.custom_public_subnet_1.id,
    aws_subnet.custom_public_subnet_2.id,
    aws_subnet.custom_private_subnet_1.id,
    aws_subnet.custom_private_subnet_2.id
  ]
}

output "sg_ids" {
  value = [
    aws_security_group.custom_public_sg_1.id,
    aws_security_group.custom_private_sg_1.id
  ]
}
