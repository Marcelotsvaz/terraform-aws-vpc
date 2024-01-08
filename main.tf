# 
# VPC
#-------------------------------------------------------------------------------
resource aws_vpc main {
	cidr_block = "10.0.0.0/16"
	assign_generated_ipv6_cidr_block = true
	enable_dns_hostnames = true
	
	tags = {
		Name = "${var.name} VPC"
	}
}


resource aws_vpc_dhcp_options main {
	domain_name = var.search_domain
	domain_name_servers = [ "AmazonProvidedDNS" ]
	
	tags = {
		Name = "${var.name} DHCP Options"
	}
}


resource aws_vpc_dhcp_options_association main {
	vpc_id = aws_vpc.main.id
	dhcp_options_id = aws_vpc_dhcp_options.main.id
}


resource aws_internet_gateway main {
	vpc_id = aws_vpc.main.id
	
	tags = {
		Name = "${var.name} Internet Gateway"
	}
}


resource aws_egress_only_internet_gateway main {
	vpc_id = aws_vpc.main.id
	
	tags = {
		Name = "${var.name} Egress-Only Internet Gateway"
	}
}



# 
# Subnets
#-------------------------------------------------------------------------------
data aws_availability_zones main {}


locals {
	availability_zones = [
		for zone_name in data.aws_availability_zones.main.names:
		zone_name
		if length( var.availability_zone_filter ) == 0
		|| contains( var.availability_zone_filter, trimprefix( zone_name, data.aws_availability_zones.main.id ) )
	]
	
	subnets = {
		for pair in setproduct( local.availability_zones, keys( var.networks ) ):
		"${pair[0]}-${pair[1]}" => {
			availability_zone = pair[0]
			network = pair[1]
			name = format(
				"${var.name} Subnet - ${var.networks[pair[1]].name}",
				upper( trimprefix( pair[0], data.aws_availability_zones.main.id ) ),
			)
			public = var.networks[pair[1]].public
			
			cidr_block = cidrsubnet(
				cidrsubnet( aws_vpc.main.cidr_block, 4, index( local.availability_zones, pair[0] ) ),
				4,
				index( keys( var.networks ), pair[1] ),
			)
			ipv6_cidr_block = cidrsubnet(
				cidrsubnet( aws_vpc.main.ipv6_cidr_block, 4, index( local.availability_zones, pair[0] ) ),
				4,
				index( keys( var.networks ), pair[1] ),
			)
		}
	}
}


resource aws_subnet main {
	for_each = local.subnets
	
	vpc_id = aws_vpc.main.id
	availability_zone = each.value.availability_zone
	cidr_block = each.value.cidr_block
	ipv6_cidr_block = each.value.ipv6_cidr_block
	map_public_ip_on_launch = each.value.public
	assign_ipv6_address_on_creation = true
	
	# Block instance creation before DHCP options is ready.
	depends_on = [ aws_vpc_dhcp_options_association.main ]
	
	tags = {
		Name = each.value.name
	}
}



# 
# Security
#-------------------------------------------------------------------------------
resource aws_default_network_acl main {
	default_network_acl_id = aws_vpc.main.default_network_acl_id
	subnet_ids = [ for index, subnet in aws_subnet.main: subnet.id ]
	
	ingress {
		rule_no = 100
		protocol = "all"
		from_port = 0
		to_port = 0
		cidr_block = "0.0.0.0/0"
		action = "allow"
	}
	
	ingress {
		rule_no = 101
		protocol = "all"
		from_port = 0
		to_port = 0
		ipv6_cidr_block = "::/0"
		action = "allow"
	}
	
	egress {
		rule_no = 100
		protocol = "all"
		from_port = 0
		to_port = 0
		cidr_block = "0.0.0.0/0"
		action = "allow"
	}
	
	egress {
		rule_no = 101
		protocol = "all"
		from_port = 0
		to_port = 0
		ipv6_cidr_block = "::/0"
		action = "allow"
	}
	
	tags = {
		Name = "${var.name} ACL"
	}
}


resource aws_default_security_group main {
	vpc_id = aws_vpc.main.id
	
	egress {
		description = "All egress traffic."
		protocol = "all"
		from_port = 0
		to_port = 0
		cidr_blocks = [ "0.0.0.0/0" ]
		ipv6_cidr_blocks = [ "::/0" ]
	}
	
	tags = {
		Name = "${var.name} Default Security Group"
	}
}