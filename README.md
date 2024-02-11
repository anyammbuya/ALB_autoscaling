# Deploying a secure Two-tier Infrastructure With High Availabilty

This is an example Terraform configuration the allows the deployment of a two-tier web architecture on AWS.

## What are the resources used in this architecture?

A VPC

Availability Zones

Internet gateway

NAT gateway

Two public subnets in two availability zones

Two private subnets in two availability zones

Route tables

Security group for the load balancer that allows traffic to port 80, and 443 from anywhere

Security group for webapp-tier that allows traffic to port 80 from load balancer security group. This security group equally allows traffic to port 80 and 443 from public subnets.

Load balancer and target groups

Launch template

auto scaling group