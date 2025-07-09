variable "vpc_cidr" {
  type = string
}
variable "enable_dns_support" {
  type = bool
}
variable "enable_dns_hostnames" {
  type = bool
}
variable "pubsub" {

  type        = list(string)
}
variable "prisub" {
 
 type  = list(string)
}
variable "pubsub_az" {

  type = list(string)
}
variable "prisub_az" {
  type  = list(string)
}
variable "create_nat" {
  type    = bool
}
variable "nat_eip_id" {
  type    = string    
}
variable "name_prefix" {

  type        = string
}

