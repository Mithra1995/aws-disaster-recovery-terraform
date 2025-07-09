variable "bucket_name_prefix" {
  type        = string
  description = "Prefix for the source (east) bucket"
}

variable "bucket_name_prefix_secondary" {
  type        = string
  description = "Prefix for the destination (west) bucket"
}
variable "enable_versioning" {
  description = "Turn on versioning for both buckets"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "Create the IAM role + CRR replication configuration"
  type        = bool
  default     = true
}