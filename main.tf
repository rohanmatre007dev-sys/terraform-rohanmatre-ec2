################################################################################
# Wrapper calls the official upstream module
# Source: terraform-aws-modules/ec2-instance/aws
# Docs:   https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws
#
# This wrapper adds:
#   - Auto naming:              rohanmatre-{env}-{region}-ec2
#   - Auto tagging:             Environment, Owner, GitHubRepo, ManagedBy
#   - Termination protection:   auto-enabled in prod
#   - Detailed monitoring:      auto-enabled in prod
#   - Root volume encryption:   auto-enabled in prod
#   - IMDSv2:                   enforced by default (http_tokens=required)
#   - Safe defaults:            t3.micro, monitoring=true, create_sg=false
################################################################################

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.3.0"

  ##############################################################################
  # General
  ##############################################################################
  create             = var.create
  enable_volume_tags = local.enable_volume_tags
  instance_tags      = var.instance_tags
  name               = local.name
  region             = var.region
  tags               = local.tags
  volume_tags        = var.volume_tags

  ##############################################################################
  # AMI
  # EXAM: AMI = Amazon Machine Image — blueprint for instance
  # EXAM: AMI is region-specific — different AMI ID per region for same OS
  # EXAM: ami_ssm_parameter auto-fetches latest Amazon Linux AMI
  ##############################################################################
  ami                = var.ami
  ami_ssm_parameter  = var.ami_ssm_parameter
  ignore_ami_changes = var.ignore_ami_changes

  ##############################################################################
  # Instance Core
  # EXAM: Instance families — t=burstable, m=general, c=compute, r=memory, i=storage
  # EXAM: t3 instances use CPU credits — standard vs unlimited
  # EXAM: Placement groups — cluster(low latency), spread(HA), partition(big data)
  ##############################################################################
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = var.availability_zone
  enable_primary_ipv6         = var.enable_primary_ipv6
  instance_type               = var.instance_type
  ipv6_address_count          = var.ipv6_address_count
  ipv6_addresses              = var.ipv6_addresses
  monitoring                  = local.monitoring
  placement_group             = var.placement_group
  placement_partition_number  = var.placement_partition_number
  private_ip                  = var.private_ip
  secondary_private_ips       = var.secondary_private_ips
  source_dest_check           = var.source_dest_check
  subnet_id                   = var.subnet_id
  tenancy                     = var.tenancy
  vpc_security_group_ids      = var.vpc_security_group_ids

  ##############################################################################
  # Dedicated Host
  ##############################################################################
  host_id                 = var.host_id
  host_resource_group_arn = var.host_resource_group_arn

  ##############################################################################
  # Key Pair
  # EXAM: Key pair = asymmetric RSA key for SSH access
  # EXAM: AWS stores public key, you keep private key locally
  # EXAM: If you lose private key — create new key pair, stop instance,
  #        modify authorized_keys via SSM or user data
  ##############################################################################
  key_name = var.key_name

  ##############################################################################
  # User Data
  # EXAM: Runs ONCE at first launch only — not on reboot or restart
  # EXAM: 16KB limit for plain text, larger scripts use S3 + curl
  # EXAM: Runs as root user
  ##############################################################################
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  ##############################################################################
  # Instance Behavior + Protection
  # EXAM: disable_api_termination — prevents accidental termination
  # EXAM: Termination protection must be disabled before you can terminate
  ##############################################################################
  disable_api_stop                     = var.disable_api_stop
  disable_api_termination              = local.disable_api_termination
  get_password_data                    = var.get_password_data
  hibernation                          = var.hibernation
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  timeouts                             = var.timeouts

  ##############################################################################
  # EBS — Root + Additional Volumes
  # EXAM: EBS types — gp3 (default, 3000 IOPS), io1/io2 (high IOPS DBs)
  # EXAM: gp3 = 20% cheaper than gp2, better performance baseline
  # EXAM: EBS volumes persist after instance termination by default
  # EXAM: delete_on_termination=true to auto-delete with instance
  # Root volume encryption auto-enforced in prod via locals
  ##############################################################################
  ebs_optimized          = var.ebs_optimized
  ebs_volumes            = var.ebs_volumes
  ephemeral_block_device = var.ephemeral_block_device
  root_block_device      = local.root_block_device

  ##############################################################################
  # Elastic IP
  # EXAM: EIP = static public IP that survives stop/start
  # EXAM: Regular public IP changes on every stop/start
  # EXAM: EIP is FREE when attached to running instance
  # EXAM: EIP costs money when NOT attached (idle EIP)
  ##############################################################################
  create_eip = var.create_eip
  eip_domain = var.eip_domain
  eip_tags   = var.eip_tags

  ##############################################################################
  # IAM Instance Profile
  # EXAM: Instance Profile = way for EC2 to assume an IAM role
  # EXAM: Never hardcode AWS credentials on EC2 — use instance profiles
  # EXAM: EC2 gets temporary credentials via metadata service (169.254.169.254)
  ##############################################################################
  create_iam_instance_profile   = var.create_iam_instance_profile
  iam_instance_profile          = var.iam_instance_profile
  iam_role_description          = var.iam_role_description
  iam_role_name                 = var.iam_role_name
  iam_role_path                 = var.iam_role_path
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_policies             = var.iam_role_policies
  iam_role_tags                 = var.iam_role_tags
  iam_role_use_name_prefix      = var.iam_role_use_name_prefix

  ##############################################################################
  # Security Group (inline — use rohanmatre-sg-wrapper instead for reusability)
  # Set create_security_group=false and pass vpc_security_group_ids from sg wrapper
  ##############################################################################
  create_security_group          = var.create_security_group
  security_group_description     = var.security_group_description
  security_group_egress_rules    = var.security_group_egress_rules
  security_group_ingress_rules   = var.security_group_ingress_rules
  security_group_name            = var.security_group_name
  security_group_tags            = var.security_group_tags
  security_group_use_name_prefix = var.security_group_use_name_prefix
  security_group_vpc_id          = var.security_group_vpc_id

  ##############################################################################
  # Spot Instance
  # EXAM: Spot = up to 90% cheaper than on-demand
  # EXAM: Spot can be interrupted by AWS with 2-minute notice
  # EXAM: Best for: batch jobs, CI/CD runners, stateless web servers
  # EXAM: Not suitable for: databases, stateful apps, long-running jobs
  ##############################################################################
  create_spot_instance                = var.create_spot_instance
  instance_market_options             = var.instance_market_options
  spot_instance_interruption_behavior = var.spot_instance_interruption_behavior
  spot_launch_group                   = var.spot_launch_group
  spot_price                          = var.spot_price
  spot_type                           = var.spot_type
  spot_valid_from                     = var.spot_valid_from
  spot_valid_until                    = var.spot_valid_until
  spot_wait_for_fulfillment           = var.spot_wait_for_fulfillment

  ##############################################################################
  # Network Interface
  ##############################################################################
  network_interface = var.network_interface

  ##############################################################################
  # Launch Template
  ##############################################################################
  launch_template = var.launch_template

  ##############################################################################
  # CPU Options
  # EXAM: cpu_credits=unlimited — T instances never throttle but cost more
  # EXAM: cpu_credits=standard — T instances throttle when credits exhausted
  ##############################################################################
  cpu_credits = var.cpu_credits
  cpu_options = var.cpu_options

  ##############################################################################
  # Capacity Reservation
  ##############################################################################
  capacity_reservation_specification = var.capacity_reservation_specification

  ##############################################################################
  # Metadata Options
  # EXAM: IMDSv2 = more secure — requires session-oriented requests
  # EXAM: IMDSv1 = deprecated, vulnerable to SSRF attacks
  # EXAM: http_tokens=required enforces IMDSv2 — always use this
  # EXAM: Metadata endpoint: http://169.254.169.254/latest/meta-data/
  ##############################################################################
  metadata_options = var.metadata_options

  ##############################################################################
  # Maintenance + Enclave + Private DNS
  ##############################################################################
  enclave_options_enabled  = var.enclave_options_enabled
  maintenance_options      = var.maintenance_options
  private_dns_name_options = var.private_dns_name_options
}
