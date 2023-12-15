# 
# Public Route Table
#-------------------------------------------------------------------------------
resource aws_default_route_table public {
	default_route_table_id = aws_vpc.main.default_route_table_id
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.main.id
	}
	
	route {
		ipv6_cidr_block = "::/0"
		gateway_id = aws_internet_gateway.main.id
	}
	
	tags = {
		Name = "${var.name} Public Route Table"
	}
}


resource aws_route_table_association public {
	for_each = {
		for index, subnet in local.flattened_subnets:
		index => aws_subnet.main[index]
		if subnet.public
	}
	
	route_table_id = aws_default_route_table.public.id
	subnet_id = each.value.id
}



# 
# Private Route Table
#-------------------------------------------------------------------------------
resource aws_route_table private {
	vpc_id = aws_vpc.main.id
	
	route {
		ipv6_cidr_block = "::/0"
		egress_only_gateway_id = aws_egress_only_internet_gateway.main.id
	}
	
	tags = {
		Name = "${var.name} Private Route Table"
	}
}


resource aws_route_table_association private {
	for_each = {
		for index, subnet in local.flattened_subnets:
		index => aws_subnet.main[index]
		if !subnet.public
	}
	
	route_table_id = aws_route_table.private.id
	subnet_id = each.value.id
}