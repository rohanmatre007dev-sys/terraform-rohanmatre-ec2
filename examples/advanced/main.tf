################################################################################
# Advanced Example
# Production-grade EC2 with IAM role, encrypted EBS, EIP, user data
#
# What gets created:
#   - 1 EC2 instance (t3.small, prod-grade settings)
#   - IAM instance profile (for S3 + SSM access — no hardcoded keys)
#   - Encrypted gp3 root volume (auto in prod via locals)
#   - Additional data EBS volume (gp3, encrypted)
#   - Elastic IP (static public IP)
#   - Termination protection (auto in prod via locals)
#   - Detailed monitoring (auto in prod via locals)
#   - IMDSv2 enforced
################################################################################

provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source  = "rohanmatre007dev-sys/vpc/rohanmatre"
  version = "1.0.1"

  environment     = "prod"
  cidr            = "10.10.0.0/16"
  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  private_subnets = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}

module "sg" {
  source  = "rohanmatre007dev-sys/sg/rohanmatre"
  version = "1.0.0"

  environment = "prod"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp", "http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["10.0.0.0/8"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "ec2" {
  source = "../../"

  name        = "rohanmatre-prod-web-server"
  environment = "prod"

  # Network
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.sg.security_group_id]
  create_security_group  = false

  # Instance
  instance_type = "t3.small"
  key_name      = "prod-key-pair"

  # Elastic IP — static public IP for prod
  create_eip = true

  # IAM — allow instance to access S3 and SSM (no hardcoded keys)
  create_iam_instance_profile = true
  iam_role_policies = {
    AmazonS3ReadOnlyAccess       = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # Additional data volume
  ebs_volumes = {
    data = {
      size      = 100
      type      = "gp3"
      encrypted = true
      iops      = 3000
    }
  }

  # Bootstrap script
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>rohanmatre prod server</h1>" > /var/www/html/index.html
  EOF

  # Prod auto-sets: termination_protection=true, monitoring=true, root_encrypted=true
  tags = {
    Project = "rohanmatre-platform"
    Role    = "web-server"
  }
}
