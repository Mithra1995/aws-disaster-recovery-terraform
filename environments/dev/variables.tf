variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "vpc_cidr_secondary" {
  default = "192.168.4.0/24"
}
variable "enable_dns_support" {
  default     = true
  description = "Enable DNS support in the VPC"
}
variable "enable_dns_hostnames" {
  default     = true
  description = "Enable DNS hostnames in the VPC"
}
variable "east_pubsubs" {
  type    = list(string)
  default = ["10.0.0.0/18", "10.0.64.0/18"]
}
variable "east_prisubs" {
  type    = list(string)
  default = ["10.0.128.0/18", "10.0.192.0/18"]
}
variable "west_pubsubs" {
  type    = list(string)
  default = ["192.168.4.0/26", "192.168.4.64/26"]
}
variable "west_prisubs" {
  type    = list(string)
  default = ["192.168.4.128/26", "192.168.4.192/26"]
}
variable "east_pubsub_azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "east_prisub_azs" {
  type    = list(string)
  default = ["us-east-1c", "us-east-1d"]
}
variable "west_pubsub_azs" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

variable "west_prisub_azs" {
  type    = list(string)
  default = ["us-west-2c", "us-west-2d"]
}
variable "nat_eip_id" {
  default = ""
}
variable "create_nat" {
  default = true
}
variable "bucket_name_prefix" {
  default = "dr-demo-east"
}
variable "bucket_name_prefix_secondary" {
  default = "dr-demo-west"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "ami_east" {
  type        = string
  description = "AMI ID for EC2 instances in east region"
  default     = "ami-05ffe3c48a9991133"
}
variable "ami_west" {
  type    = string
  default = "ami-05ee755be0cd7555c"
}
variable "subnet_id" {
  type    = string
  default = ""
}
variable "env" {
  default = "dev"
}
variable "launch_template_id" {
  default = ""
}
variable "desired_capacity" {
  default = 1
}
variable "min_size" {
  default = 1
}
variable "max_size" {
  default = 1
}
variable "alb_https_enabled" {
  description = "Enable HTTPS listener for ALB"
  type        = bool
  default     = false
}

variable "alb_ssl_policy" {
  description = "SSL Policy for HTTPS ALB listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN for HTTPS listener"
  type        = string
  default     = "" # or paste your actual ACM ARN here
}
variable "db_master_username" { type = string }
variable "db_master_password" { type = string }

variable "name_prefix" {
  description = "Prefix to identify resources uniquely"
  type        = string
  default     = "dev"
}