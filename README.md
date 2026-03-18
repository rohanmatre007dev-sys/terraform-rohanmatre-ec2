# terraform-rohanmatre-ec2

Terraform wrapper module for AWS EC2 instances — built on top of [terraform-aws-modules/ec2-instance/aws](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws).

This wrapper adds:
- **Auto naming** → `rohanmatre-{environment}-{region}-ec2`
- **Auto tagging** → `Environment`, `Owner`, `GitHubRepo`, `ManagedBy`
- **Termination protection** → auto-enabled in prod
- **Detailed monitoring** → auto-enabled in prod
- **Root volume encryption** → auto-enforced in prod
- **IMDSv2** → enforced by default (`http_tokens=required`)
- **Safe defaults** → `t3.micro`, `monitoring=true`, `create_security_group=false`

---

## Dependencies

This wrapper consumes outputs from:

```hcl
subnet_id              = module.vpc.private_subnet_ids[0]  # rohanmatre-vpc-wrapper
vpc_security_group_ids = [module.sg.security_group_id]     # rohanmatre-sg-wrapper
```

---

## Usage

### Basic (dev)

```hcl
module "ec2" {
  source  = "rohanmatre007dev-sys/ec2/rohanmatre"
  version = "1.0.0"

  environment            = "dev"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.sg.security_group_id]
  key_name               = "my-key-pair"
  create_security_group  = false
}
```

### Advanced (prod with IAM + EBS + EIP)

```hcl
module "ec2" {
  source  = "rohanmatre007dev-sys/ec2/rohanmatre"
  version = "1.0.0"

  environment            = "prod"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.sg.security_group_id]
  instance_type          = "t3.small"
  create_security_group  = false
  create_eip             = true

  create_iam_instance_profile = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  ebs_volumes = {
    data = { size = 100, type = "gp3", encrypted = true }
  }
}
```

---

## Environment-Aware Behavior

| Setting | dev / stage | prod |
|---|---|---|
| Termination protection | Off | Auto-enabled |
| Detailed monitoring | Off by default | Auto-enabled |
| Root volume encryption | Not enforced | Auto-enforced (gp3 + encrypted) |
| IMDSv2 | Enforced (always) | Enforced (always) |

---

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `create` | Controls whether resources will be created | `bool` | `true` |
| `region` | AWS region | `string` | `"ap-south-1"` |
| `environment` | Environment: dev, stage, prod | `string` | `"dev"` |
| `name` | Instance name. Auto-generated if null | `string` | `null` |
| `instance_type` | EC2 instance type | `string` | `"t3.micro"` |
| `ami` | AMI ID. Uses latest Amazon Linux 2023 if null | `string` | `null` |
| `subnet_id` | Subnet ID from rohanmatre-vpc-wrapper | `string` | `null` |
| `vpc_security_group_ids` | SG IDs from rohanmatre-sg-wrapper | `list(string)` | `[]` |
| `key_name` | Key pair name for SSH access | `string` | `null` |
| `monitoring` | Enable detailed CloudWatch monitoring | `bool` | `true` |
| `create_eip` | Create and attach an Elastic IP | `bool` | `false` |
| `create_iam_instance_profile` | Create IAM instance profile and role | `bool` | `false` |
| `create_spot_instance` | Create Spot instance instead of On-Demand | `bool` | `false` |
| `create_security_group` | Create inline SG. Set false when using sg-wrapper. | `bool` | `false` |
| `user_data` | Bootstrap script (runs once at first launch) | `string` | `null` |
| `tags` | Additional tags | `map(string)` | `{}` |

Full list: [variables.tf](variables.tf)

---

## Outputs

| Name | Description | Consumed By |
|---|---|---|
| `id` | EC2 instance ID | ALB target groups, Route53 |
| `private_ip` | Private IP address | Internal service discovery |
| `public_ip` | Public IP (use EIP for static) | DNS records |
| `iam_role_arn` | ARN of instance IAM role | Cross-account policies |
| `iam_instance_profile_arn` | ARN of instance profile | Reference |
| `availability_zone` | AZ of instance | EBS volume placement |
| `instance_state` | Current state of instance | Health checks |
| `security_group_id` | SG ID (only when create_security_group=true) | Reference |

Full list: [outputs.tf](outputs.tf)

---

## Notes

- Auto-generates name as `rohanmatre-{environment}-{region}-ec2`
- IMDSv2 always enforced (`http_tokens=required`) — protects against SSRF attacks
- Set `create_security_group=false` and use `vpc_security_group_ids` from `rohanmatre-sg-wrapper`
- Upstream module: [terraform-aws-modules/ec2-instance/aws >= 6.28](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws)
- Default region: `ap-south-1`

---

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.5.7 |
| aws | >= 6.28 |
