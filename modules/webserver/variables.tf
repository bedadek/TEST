variable "cloud_public_subnets" { 
  description = "Public Subnets ID for webservers"
  type = list(any)
}

variable "cloud_vpc_id" {
  description = "VPC Id"
  type = string
  validation {
    condition = length(var.cloud_vpc_id) > 4 && substr(var.cloud_vpc_id, 0, 4) == "vpc-"
    error_message = "VPC ID must not be empty"
  }
}

variable "ingress_rules" {
  type = list(object({
    port = number
    proto = string
    cidr_blocks = list(string)
  }))
  default = [ 
    {
    cidr_blocks = [ "0.0.0.0/0" ]
    port = 80
    proto = "tcp"
  },
  {
    port = 22
    proto = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ]
}

