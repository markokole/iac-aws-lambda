output vpc_id {
  value = module.vpc.vpc_id
}

output aws_security_group_id {
  value = aws_security_group.lambda_sg.id
}

output public_ip {
    value = module.ec2_cluster.public_ip
}

output availability_zone {
  value = module.vpc.azs
}

output vpc_cidr_block {
  value = module.vpc.vpc_cidr_block
}

output subnet_ids {
  value = module.vpc.public_subnets
}

output nat_public_ip {
  value = aws_eip.nat.*.public_ip
}
