variable "name_prefix" { type = string }
variable "env"         { type = string }
variable "vpc_id"      { type = string }

variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "internal" {
  type    = bool
  default = false
}

variable "https_enabled" {
  type    = bool
  default = false
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-2016-08"
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "user_data" {
  type    = string
  default = "#!/bin/bash\nyum -y install httpd && systemctl start httpd"
}

