variable name {
	description = "VPC name."
	type = string
}

variable search_domain {
	description = "DHCP search domain."
	type = string
	default = null
}

variable cidr_block {
	description = "VPC IPv4 block in CIDR notation."
	type = string
	default = "10.0.0.0/16"
}

variable nat_network_interface_id {
	description = "ID of a network interface responsible for NAT."
	type = string
	default = null
}

variable availability_zone_filter {
	description = "List of allowed availability zones in the form of lowercase letters. Defaults to all zones."
	type = list( string )
	default = []
	
	validation {
		condition = alltrue( [ for zone in var.availability_zone_filter: length( regexall( "^[a-z]$", zone ) ) > 0 ] )
		error_message = "Invalid availability zone."
	}
}

variable networks {
	description = "Mapping of subnets, mirrored across multiple availability zones. Use `%s` in the name to substitute the zone letter."
	
	type = map( object( {
		name = string
		public = optional( bool, false )
	} ) )
	
	default = {
		public = {
			name = "%s - Public"
			public = true
		}
	}
}