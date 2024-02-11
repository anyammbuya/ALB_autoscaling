variable "subnet_ids" {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}
variable "target_group_arns" {
  description = "ARN of the target group"
  type        = list(string)
}
variable "launch_template_id" {
  description = "ID of launch template"
  type        = string
}
variable "launch_template_version" {
  description = "version of launch template"
  type        = string
}
