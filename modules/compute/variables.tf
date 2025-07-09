variable "name_prefix"        { type = string }
variable "env"                { type = string }

variable "ami"                { type = string }
variable "instance_type"      { type = string }

variable "desired_capacity"   { type = number }
variable "min_size"           { type = number }
variable "max_size"           { type = number }

variable "vpc_id"             { type = string }
variable "subnet_ids"         { type = list(string) }

variable "target_group_arn"   { type = string }
variable "user_data" {
  description = "User data script to initialize EC2 instance"
  type        = string
  default     = ""
}
variable "instance_profile"    { type = string }  
