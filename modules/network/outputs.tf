output "vpc_id" {
  value = aws_vpc.project_VPC.id
}
output "public_subnet_ids" {
  value = [for subnet in aws_subnet.pubsub : subnet.id]
}
output "private_subnet_ids" {
  value = [for s in aws_subnet.prisub : s.id]
}

output "east_public_subnet_ids" {
  value = aws_subnet.pubsub[*].id
}
output "west_public_subnet_ids" {
  value = aws_subnet.pubsub[*].id
}

