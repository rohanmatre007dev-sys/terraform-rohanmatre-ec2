################################################################################
# General
################################################################################

variable "create" {
  description = "Controls whether EC2 instance and all resources will be created"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region where EC2 instance will be created"
  type        = string
  # default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "name" {
  description = "Name of the EC2 instance. Auto-generated if null."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags merged with common tags"
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Additional tags for the EC2 instance only"
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "Tags to assign to volumes created by the instance at launch time"
  type        = map(string)
  default     = {}
}

variable "enable_volume_tags" {
  description = "Whether to enable volume tags (conflicts with root_block_device tags if both set)"
  type        = bool
  default     = true
}

################################################################################
# AMI
# EXAM: AMI = Amazon Machine Image — blueprint for EC2 instance
# EXAM: AMI is region-specific — cannot use AMI from one region in another
# EXAM: ami_ssm_parameter auto-fetches latest Amazon Linux AMI
################################################################################

variable "ami" {
  description = "ID of AMI to use. If null, ami_ssm_parameter is used to fetch latest."
  type        = string
  default     = null
}

variable "ami_ssm_parameter" {
  description = "SSM parameter path to fetch AMI ID. Defaults to latest Amazon Linux 2023."
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "ignore_ami_changes" {
  description = "Ignore AMI ID changes after initial creation (prevents instance replacement)"
  type        = bool
  default     = false
}

################################################################################
# Instance Core
# EXAM: Instance types — t3 (burstable), m5 (general), c5 (compute), r5 (memory)
# EXAM: t3.micro is free tier eligible
# EXAM: Placement groups — cluster (low latency), spread (HA), partition (big data)
################################################################################

variable "instance_type" {
  description = "EC2 instance type. t3.micro = free tier."
  type        = string
  default     = "t3.micro"
}

variable "availability_zone" {
  description = "AZ to launch instance in. Auto-derived if null."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID to launch instance in. From rohanmatre-vpc-wrapper output."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs. From rohanmatre-sg-wrapper output."
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Associate a public IP with instance. Only for public subnets."
  type        = bool
  default     = null
}

variable "private_ip" {
  description = "Static private IP to assign to instance"
  type        = string
  default     = null
}

variable "secondary_private_ips" {
  description = "List of secondary private IPv4 addresses for primary network interface"
  type        = list(string)
  default     = null
}

variable "ipv6_address_count" {
  description = "Number of IPv6 addresses to associate with primary network interface"
  type        = number
  default     = null
}

variable "ipv6_addresses" {
  description = "Specific IPv6 addresses from subnet range for primary network interface"
  type        = list(string)
  default     = null
}

variable "enable_primary_ipv6" {
  description = "Assign a primary IPv6 GUA to instance in dual-stack or IPv6-only subnet"
  type        = bool
  default     = null
}

variable "source_dest_check" {
  description = "Controls traffic routing when destination address does not match instance. Disable for NAT/VPN."
  type        = bool
  default     = null
}

variable "monitoring" {
  description = "Enable detailed CloudWatch monitoring (1-minute intervals). Basic = free, detailed = charged."
  type        = bool
  default     = true
}

variable "tenancy" {
  description = "Instance tenancy: default, dedicated, or host"
  type        = string
  default     = null
}

variable "host_id" {
  description = "ID of dedicated host for instance placement"
  type        = string
  default     = null
}

variable "host_resource_group_arn" {
  description = "ARN of host resource group for instance placement"
  type        = string
  default     = null
}

variable "placement_group" {
  description = "Placement Group name for the instance"
  type        = string
  default     = null
}

variable "placement_partition_number" {
  description = "Partition number when using partition placement group strategy"
  type        = number
  default     = null
}

################################################################################
# Key Pair
# EXAM: Key pair = SSH access to EC2. Private key stored locally, public key in AWS.
# EXAM: Lost private key = no SSH access — create new key pair
################################################################################

variable "key_name" {
  description = "Name of the Key Pair for SSH access to the instance"
  type        = string
  default     = null
}

################################################################################
# User Data
# EXAM: User data runs at FIRST launch only (not on reboot)
# EXAM: Limited to 16KB
# EXAM: Used for bootstrapping — install packages, start services
################################################################################

variable "user_data" {
  description = "User data script to run at launch (plain text). Max 16KB."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data. Use for binary/gzip-compressed scripts."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Trigger instance replacement when user data changes"
  type        = bool
  default     = null
}

################################################################################
# Instance Behavior
################################################################################

variable "disable_api_termination" {
  description = "Enable termination protection. Prevents accidental deletion in prod."
  type        = bool
  default     = null
}

variable "disable_api_stop" {
  description = "Enable stop protection. Prevents accidental stop in prod."
  type        = bool
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Behavior on shutdown: stop (EBS-backed default) or terminate"
  type        = string
  default     = null
}

variable "hibernation" {
  description = "Enable hibernation support for the instance"
  type        = bool
  default     = null
}

variable "get_password_data" {
  description = "Retrieve encrypted Windows administrator password"
  type        = bool
  default     = null
}

variable "timeouts" {
  description = "Timeout settings for create, update, and delete operations"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

################################################################################
# EBS Optimized + Root Block Device
# EXAM: EBS types — gp3 (default), gp2, io1/io2 (high IOPS), st1 (throughput), sc1 (cold)
# EXAM: gp3 = cheaper than gp2, 3000 IOPS baseline, up to 16000 IOPS
# EXAM: io1/io2 = for databases requiring > 16000 IOPS
################################################################################

variable "ebs_optimized" {
  description = "Launch with EBS-optimized instance (dedicated bandwidth to EBS)"
  type        = bool
  default     = null
}

variable "root_block_device" {
  description = "Root EBS volume configuration (size, type, encryption)"
  type = object({
    delete_on_termination = optional(bool)
    encrypted             = optional(bool)
    iops                  = optional(number)
    kms_key_id            = optional(string)
    tags                  = optional(map(string))
    throughput            = optional(number)
    size                  = optional(number)
    type                  = optional(string)
  })
  default = null
}

variable "ebs_volumes" {
  description = "Map of additional EBS volumes to create and attach to instance"
  type = map(object({
    encrypted                      = optional(bool)
    final_snapshot                 = optional(bool)
    iops                           = optional(number)
    kms_key_id                     = optional(string)
    multi_attach_enabled           = optional(bool)
    outpost_arn                    = optional(string)
    size                           = optional(number)
    snapshot_id                    = optional(string)
    tags                           = optional(map(string), {})
    throughput                     = optional(number)
    type                           = optional(string, "gp3")
    volume_initialization_rate     = optional(number)
    device_name                    = optional(string)
    force_detach                   = optional(bool)
    skip_destroy                   = optional(bool)
    stop_instance_before_detaching = optional(bool)
  }))
  default = null
}

variable "ephemeral_block_device" {
  description = "Customize instance store (ephemeral) volumes"
  type = map(object({
    device_name  = string
    no_device    = optional(bool)
    virtual_name = optional(string)
  }))
  default = null
}

################################################################################
# Elastic IP
# EXAM: EIP = static public IP that persists even if instance stops/restarts
# EXAM: EIP is free when attached to running instance, charged when NOT attached
################################################################################

variable "create_eip" {
  description = "Create and associate an Elastic IP with the instance"
  type        = bool
  default     = false
}

variable "eip_domain" {
  description = "EIP domain. Must be vpc."
  type        = string
  default     = "vpc"
}

variable "eip_tags" {
  description = "Additional tags for the EIP"
  type        = map(string)
  default     = {}
}

################################################################################
# IAM Instance Profile
# EXAM: Instance Profile = how EC2 gets permissions to call AWS APIs
# EXAM: EC2 uses instance profile role to access S3, DynamoDB, SSM etc.
# EXAM: Never store AWS keys on EC2 — use instance profiles instead
################################################################################

variable "create_iam_instance_profile" {
  description = "Create an IAM instance profile and role for the instance"
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile name to attach (when create_iam_instance_profile=false)"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name for the IAM role created with the instance"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of permissions boundary policy for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Map of IAM policy ARNs to attach to the instance role"
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "Additional tags for the IAM role and instance profile"
  type        = map(string)
  default     = {}
}

variable "iam_role_use_name_prefix" {
  description = "Use iam_role_name as a prefix for the IAM role name"
  type        = bool
  default     = true
}

################################################################################
# Security Group (built-in to EC2 module)
# Note: For reusable SGs, use rohanmatre-sg-wrapper + vpc_security_group_ids
# create_security_group = false when using rohanmatre-sg-wrapper
################################################################################

variable "create_security_group" {
  description = "Create a security group within this module. Set false if using rohanmatre-sg-wrapper."
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name for the inline security group"
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description of the inline security group"
  type        = string
  default     = null
}

variable "security_group_vpc_id" {
  description = "VPC ID for the inline security group"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Use security_group_name as prefix"
  type        = bool
  default     = true
}

variable "security_group_tags" {
  description = "Additional tags for the inline security group"
  type        = map(string)
  default     = {}
}

variable "security_group_ingress_rules" {
  description = "Ingress rules for inline security group"
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(number)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(number)
  }))
  default = null
}

variable "security_group_egress_rules" {
  description = "Egress rules for inline security group"
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(number)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(number)
  }))
  default = {
    ipv4_default = {
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all IPv4 traffic"
      ip_protocol = "-1"
    }
    ipv6_default = {
      cidr_ipv6   = "::/0"
      description = "Allow all IPv6 traffic"
      ip_protocol = "-1"
    }
  }
}

################################################################################
# Spot Instance
# EXAM: Spot = up to 90% cheaper, but can be interrupted by AWS with 2-min notice
# EXAM: Spot = good for stateless, fault-tolerant workloads (batch, CI/CD)
# EXAM: On-demand = regular price, no interruption
# EXAM: Reserved = 1-3 year commitment, up to 72% discount
################################################################################

variable "create_spot_instance" {
  description = "Create a Spot instance instead of On-Demand"
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "Maximum price for spot instance. Defaults to on-demand price."
  type        = string
  default     = null
}

variable "spot_type" {
  description = "Spot request type: persistent or one-time"
  type        = string
  default     = null
}

variable "spot_launch_group" {
  description = "Spot launch group — instances launch and terminate together"
  type        = string
  default     = null
}

variable "spot_instance_interruption_behavior" {
  description = "Behavior when spot interrupted: terminate, stop, or hibernate"
  type        = string
  default     = null
}

variable "spot_valid_from" {
  description = "Start time for spot request in UTC RFC3339 format"
  type        = string
  default     = null
}

variable "spot_valid_until" {
  description = "End time for spot request in UTC RFC3339 format"
  type        = string
  default     = null
}

variable "spot_wait_for_fulfillment" {
  description = "Wait for spot request to be fulfilled (10m timeout)"
  type        = bool
  default     = null
}

variable "instance_market_options" {
  description = "Market (purchasing) option for instance. Overrides create_spot_instance."
  type = object({
    market_type = optional(string)
    spot_options = optional(object({
      instance_interruption_behavior = optional(string)
      max_price                      = optional(string)
      spot_instance_type             = optional(string)
      valid_until                    = optional(string)
    }))
  })
  default = null
}

################################################################################
# Network Interface
################################################################################

variable "network_interface" {
  description = "Custom network interfaces at boot. Cannot use with vpc_security_group_ids or subnet_id."
  type = map(object({
    delete_on_termination = optional(bool)
    device_index          = optional(number)
    network_card_index    = optional(number)
    network_interface_id  = string
  }))
  default = null
}

################################################################################
# Launch Template
################################################################################

variable "launch_template" {
  description = "Launch Template to configure instance. Overrides matching parameters."
  type = object({
    id      = optional(string)
    name    = optional(string)
    version = optional(string)
  })
  default = null
}

################################################################################
# CPU Options
################################################################################

variable "cpu_options" {
  description = "CPU options at launch time (core count, threads per core)"
  type = object({
    amd_sev_snp      = optional(string)
    core_count       = optional(number)
    threads_per_core = optional(number)
  })
  default = null
}

variable "cpu_credits" {
  description = "CPU credit option for T-type instances: standard or unlimited"
  type        = string
  default     = null
}

################################################################################
# Capacity Reservation
################################################################################

variable "capacity_reservation_specification" {
  description = "Capacity Reservation targeting option for the instance"
  type = object({
    capacity_reservation_preference = optional(string)
    capacity_reservation_target = optional(object({
      capacity_reservation_id                 = optional(string)
      capacity_reservation_resource_group_arn = optional(string)
    }))
  })
  default = null
}

################################################################################
# Metadata Options
# EXAM: IMDSv2 (http_tokens=required) is the secure default
# EXAM: IMDSv1 = less secure, deprecated
# EXAM: Instance metadata = http://169.254.169.254/latest/meta-data/
################################################################################

variable "metadata_options" {
  description = "Instance metadata options. IMDSv2 (http_tokens=required) enforced by default."
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_protocol_ipv6          = optional(string)
    http_put_response_hop_limit = optional(number, 1)
    http_tokens                 = optional(string, "required")
    instance_metadata_tags      = optional(string)
  })
  default = {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
}

################################################################################
# Maintenance + Enclave
################################################################################

variable "maintenance_options" {
  description = "Maintenance options for the instance (auto_recovery)"
  type = object({
    auto_recovery = optional(string)
  })
  default = null
}

variable "enclave_options_enabled" {
  description = "Enable AWS Nitro Enclaves on the instance"
  type        = bool
  default     = null
}

################################################################################
# Private DNS
################################################################################

variable "private_dns_name_options" {
  description = "Private DNS hostname options for the instance"
  type = object({
    enable_resource_name_dns_a_record    = optional(bool)
    enable_resource_name_dns_aaaa_record = optional(bool)
    hostname_type                        = optional(string)
  })
  default = null
}
