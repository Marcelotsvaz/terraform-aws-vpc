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

variable subnets {
	description = "Map of named subnet group definitions. Each definition will create one subnet per availability zone."
	
	type = map( object( {
		name = string
		availability_zone = optional( string, "all" )
		public = optional( bool, false )
	} ) )
	
	default = {
		public = {
			name = "Public"
			public = true
		}
		
		private = {
			name = "Private"
		}
	}
}