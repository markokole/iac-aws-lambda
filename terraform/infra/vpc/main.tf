# module "iam" {
#     source            = "../iam"
# }

# data "aws_security_group" "default" {
#   name   = "default"
#   vpc_id = module.vpc.vpc_id
# }

resource "aws_eip" "nat" {
  count = 1
  vpc = true

  tags = {
    Name = var.name
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = "10.0.0.0/16"

  #azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  #public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  azs             = ["eu-north-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true
  single_nat_gateway = true
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat.*.id
  enable_ec2_endpoint              = true
  ec2_endpoint_security_group_ids  = [aws_security_group.lambda_sg.id]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "${var.name}-cluster"
  instance_count         = var.launch_test_ec2

  ami                    = "ami-0b7a46b4bd694e8a6" # Amazon Linux 2 AMI 2.0.20200406.0 x86_64 HVM gp2
  instance_type          = "t3.micro"
  key_name               = "terraform-ecs"
  monitoring             = true
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.lambda_sg.id]
  subnet_ids             = module.vpc.public_subnets

  root_block_device = [{
    volume_size = 500
    delete_on_termination = true
  }]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.name}-sg"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
    description = ""
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 80"
  }
 
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = [ingress.value["ip"]]
      description = ingress.value["desc"]
    }
  }

  tags = {
    Name = var.name
  }
}