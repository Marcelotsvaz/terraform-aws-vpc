output id {
	description = "VPC ID."
	value = aws_vpc.main.id
}

output networks {
	description = "Mapping of subnets, mirrored across multiple availability zones."
	value = {
		for key, subnet in aws_subnet.main:
		local.subnets[key].network => subnet...
	}
}