# General
variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "project" {
  type    = string
  default = "governed-demo"
}

variable "environment" {
  type    = string
  default = "demo"
}


# Networking layer
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# App layer
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# Db layer
variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_username" {
  type    = string
  default = "appadmin"
}
