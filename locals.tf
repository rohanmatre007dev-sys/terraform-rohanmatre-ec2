locals {
  ##############################################################################
  # Naming
  # Pattern: rohanmatre-{environment}-{region}-ec2
  # Example: rohanmatre-dev-ap-south-1-ec2
  ##############################################################################
  local_name = "rohanmatre-${var.environment}-${var.region}-ec2"
  name       = var.name == null ? local.local_name : var.name

  ##############################################################################
  # Environment-Aware Logic
  # EXAM: Prod should have termination protection enabled
  # EXAM: Prod should use detailed monitoring (1-minute intervals)
  ##############################################################################
  is_prod = var.environment == "prod"

  # Termination protection — auto-enable in prod
  disable_api_termination = local.is_prod ? true : var.disable_api_termination

  # Detailed monitoring — always on in prod
  monitoring = local.is_prod ? true : var.monitoring

  # Root volume encryption — enforced in prod
  root_block_device = local.is_prod && var.root_block_device == null ? {
    encrypted             = true
    type                  = "gp3"
    delete_on_termination = true
    iops                  = null
    kms_key_id            = null
    tags                  = {}
    throughput            = null
    size                  = null
  } : var.root_block_device

  enable_volume_tags = local.is_prod && var.root_block_device == null ? false : var.enable_volume_tags


  ##############################################################################
  # Common Tags
  ##############################################################################
  common_tags = {
    Environment = var.environment
    Owner       = "rohanmatre"
    GitHubRepo  = "terraform-rohanmatre-ec2"
    ManagedBy   = "terraform"
  }

  tags = merge(local.common_tags, var.tags, { Name = local.name })
}
