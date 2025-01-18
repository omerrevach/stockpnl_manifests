variable "vpc_id" {
  type        = string
}

variable "igw_id" {
  type        = string
}

variable "nat_instance_network_interface_id" {
  type        = string
}

variable "public_subnet_ids" {
  type        = list(string)
}

variable "private_subnet_ids" {
  type        = list(string)
}

variable "name" {
  type        = string
}
