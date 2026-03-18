output "instance_id" { value = module.ec2.id }
output "private_ip" { value = module.ec2.private_ip }
output "private_dns" { value = module.ec2.private_dns }
output "ami" { value = module.ec2.ami }
output "instance_state" { value = module.ec2.instance_state }
