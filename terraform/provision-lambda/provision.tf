locals {
    name = "lambda"
}

module "vpc" {
    source            = "../infra/vpc"
    name              = local.name
    launch_test_ec2   = 1

    ingress_rules = [
      {
        port        = 22
        ip          = "84.211.XXX.XXX/32"
        protocol    = "tcp"
        desc        = "Home"
      }
    ]
}

# module "lambda" {
#     source            = "../infra/lambda"
# }