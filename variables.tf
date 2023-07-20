variable "region" {
  description = "Default AWS region"
}

variable "cidr_pub_sub" {
  description = "Cidrs for public subnets"
}

variable "cidr_priv_sub" {
  description = "Cidrs for private subnets"
}

variable "avail_zone" {
  description = "Availability zones"
}

variable "vpc_cidr" {
  default = "12.0.0.0/16"
  description = "CIDR for vpc"
}