variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "public_route_table_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}
