# 
# Public Route Table
#-------------------------------------------------------------------------------
resource aws_default_route_table public {
	default_route_table_id = aws_vpc.main.default_route_table_id
	
	tags = {
		Name = "${var.name} Public Route Table"
	}
}


resource aws_route_table_association public {
	for_each = {
		for index, subnet in aws_subnet.main:
		subnet.id => subnet
		if local.flattened_subnets[index].public
	}
	
	route_table_id = aws_default_route_table.public.id
	subnet_id = each.key
}


resource aws_route_table_association internet_gateway {
	route_table_id = aws_default_route_table.public.id
	gateway_id = aws_internet_gateway.main.id
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
		for index, subnet in aws_subnet.main:
		subnet.id => subnet
		if !local.flattened_subnets[index].public
	}
	
	route_table_id = aws_route_table.private.id
	subnet_id = each.key
}