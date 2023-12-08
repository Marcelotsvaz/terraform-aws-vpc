output id {
	description = "VPC ID."
	value = aws_vpc.main.id
}

output subnets {
	description = "VPC subnets."
	value = aws_subnet.main[*]
}