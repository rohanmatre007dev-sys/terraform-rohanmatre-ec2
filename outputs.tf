################################################################################
# Instance Core Outputs
################################################################################

output "id" {
  description = "ID of the EC2 instance — consumed by ALB target groups, Route53 records"
  value       = module.ec2.id
}

output "arn" {
  description = "ARN of the EC2 instance"
  value       = module.ec2.arn
}

output "instance_state" {
  description = "Current state of the instance: pending, running, stopping, stopped, terminated"
  value       = module.ec2.instance_state
}

output "ami" {
  description = "AMI ID used to create the instance"
  value       = module.ec2.ami
}

output "availability_zone" {
  description = "AZ where the instance was launched"
  value       = module.ec2.availability_zone
}

output "tags_all" {
  description = "All tags assigned to the instance including provider default_tags"
  value       = module.ec2.tags_all
}

################################################################################
# Network Outputs
# Consumed by: Route53 wrapper, ALB wrapper, other instances
################################################################################

output "private_ip" {
  description = "Private IP address of the instance — use for internal communication"
  value       = module.ec2.private_ip
}

output "private_dns" {
  description = "Private DNS hostname — only resolvable inside the VPC"
  value       = module.ec2.private_dns
}

output "public_ip" {
  description = "Public IP address of instance (changes on stop/start — use EIP for static)"
  value       = module.ec2.public_ip
}

output "public_dns" {
  description = "Public DNS hostname — only available if VPC has DNS hostnames enabled"
  value       = module.ec2.public_dns
}

output "ipv6_addresses" {
  description = "IPv6 addresses assigned to the instance"
  value       = module.ec2.ipv6_addresses
}

output "primary_network_interface_id" {
  description = "ID of the primary network interface (eth0)"
  value       = module.ec2.primary_network_interface_id
}

output "outpost_arn" {
  description = "ARN of the Outpost the instance is assigned to (if applicable)"
  value       = module.ec2.outpost_arn
}

output "password_data" {
  description = "Encrypted Windows administrator password (only if get_password_data=true)"
  value       = module.ec2.password_data
  sensitive   = true
}

################################################################################
# Block Device Outputs
################################################################################

output "root_block_device" {
  description = "Root block device attributes"
  value       = module.ec2.root_block_device
}

output "ebs_block_device" {
  description = "EBS block device attributes"
  value       = module.ec2.ebs_block_device
}

output "ebs_volumes" {
  description = "Map of additional EBS volumes created and their attributes"
  value       = module.ec2.ebs_volumes
}

output "ephemeral_block_device" {
  description = "Ephemeral (instance store) block device attributes"
  value       = module.ec2.ephemeral_block_device
}

output "capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance"
  value       = module.ec2.capacity_reservation_specification
}

################################################################################
# IAM Outputs
# Consumed by: policies that reference the instance role
################################################################################

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the instance"
  value       = module.ec2.iam_role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role attached to the instance"
  value       = module.ec2.iam_role_name
}

output "iam_role_unique_id" {
  description = "Unique ID of the IAM role"
  value       = module.ec2.iam_role_unique_id
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = module.ec2.iam_instance_profile_arn
}

output "iam_instance_profile_id" {
  description = "ID of the IAM instance profile"
  value       = module.ec2.iam_instance_profile_id
}

output "iam_instance_profile_unique" {
  description = "Unique ID of the IAM instance profile"
  value       = module.ec2.iam_instance_profile_unique
}

################################################################################
# Security Group Outputs (only when create_security_group=true)
################################################################################

output "security_group_arn" {
  description = "ARN of the inline security group (only when create_security_group=true)"
  value       = module.ec2.security_group_arn
}

output "security_group_id" {
  description = "ID of the inline security group (only when create_security_group=true)"
  value       = module.ec2.security_group_id
}

################################################################################
# Spot Instance Outputs
################################################################################

output "spot_bid_status" {
  description = "Current bid status of the Spot Instance Request"
  value       = module.ec2.spot_bid_status
}

output "spot_instance_id" {
  description = "Instance ID currently fulfilling the Spot Instance Request"
  value       = module.ec2.spot_instance_id
}

output "spot_request_state" {
  description = "Current request state of the Spot Instance Request"
  value       = module.ec2.spot_request_state
}
