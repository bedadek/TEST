variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16" 
}

variable "public_subnet_cidrs" {
  type = list(string)
  description = "ip address range for public subnets"
}

variable "availability_zones" {
  type = list(string)
  description = "availability zones for the subnets"
}

variable "private_subnet_cidrs" {
  type = list(string)
  description = "ip address range for private subnets"
}