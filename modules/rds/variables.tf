variable "project" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_allocated_storage" {
  type = number
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}
