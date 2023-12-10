output id {
	description = "VPC ID."
	value = aws_vpc.main.id
}

output subnets {
	description = "Map of named subnet groups in different availability zones."
	value = {
		for index, subnet in aws_subnet.main:
		local.flattened_subnets[index].identifier => subnet...
	}
}