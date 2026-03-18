output "instance_id" { value = module.ec2.id }
output "private_ip" { value = module.ec2.private_ip }
output "public_ip" { value = module.ec2.public_ip }
output "iam_role_arn" { value = module.ec2.iam_role_arn }
output "iam_instance_profile_arn" { value = module.ec2.iam_instance_profile_arn }
output "ebs_volumes" { value = module.ec2.ebs_volumes }
output "availability_zone" { value = module.ec2.availability_zone }
output "instance_state" { value = module.ec2.instance_state }
