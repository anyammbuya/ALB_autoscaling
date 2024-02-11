# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "launch_template_id" {
  description = "IDs of EC2 instances"
  value       = aws_launch_template.project-zeus-LT.id
}
output "launch_template_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.project-zeus-LT.latest_version
}