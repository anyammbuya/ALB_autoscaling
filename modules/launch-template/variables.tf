# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


variable "instance_type" {
  description = "Type of EC2 instance to yese"
  type        = string
}
variable "tags" {
  description = "tags to apply to instances"
  type        = map(string)
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable "instance_profile_arn" {
  description = "arn of the ec2 instance profile"
  
}

