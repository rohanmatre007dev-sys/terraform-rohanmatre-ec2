################################################################################
# Basic Example
# Simple EC2 instance in private subnet — most common real-world pattern
#
# What gets created:
#   - 1 EC2 instance (t3.micro, Amazon Linux 2023)
#   - Uses existing VPC + SG from rohanmatre wrappers
#   - IMDSv2 enforced (secure metadata access)
#   - Detailed monitoring enabled
#
# Auto-generated name: rohanmatre-dev-ap-south-1-ec2
################################################################################

provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source  = "rohanmatre007dev-sys/vpc/rohanmatre"
  version = "1.0.0"

  environment = "dev"
}

module "sg" {
  source  = "rohanmatre007dev-sys/sg/rohanmatre"
  version = "1.0.0"

  environment = "dev"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["10.0.0.0/8"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "ec2" {
  source = "../../"

  environment = "dev"

  # Network — from vpc + sg wrappers
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.sg.security_group_id]

  # Instance
  instance_type = "t3.micro"
  key_name      = "my-key-pair"

  # Do NOT create inline SG — using rohanmatre-sg-wrapper above
  create_security_group = false
}
