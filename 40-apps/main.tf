module "mysql" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  
  ami = data.aws_ami.joindevops.id
  name = "${local.resource_name}-mysql"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.mysql_sg_id]
  subnet_id              = local.database_subnet_id

  tags = merge(
    var.common_tags,
    var.mysql_tags,
    {
        Name = "${local.resource_name}-mysql"
    }
  )
}

module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  
  ami = data.aws_ami.joindevops.id
  name = "${local.resource_name}-backend"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.backend_sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge(
    var.common_tags,
    var.backend_tags,
    {
        Name = "${local.resource_name}-backend"
    }
  )
}

module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  
  ami = data.aws_ami.joindevops.id
  name = "${local.resource_name}-frontend"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.frontend_sg_id]
  subnet_id              = local.public_subnet_id

  tags = merge(
    var.common_tags,
    var.frontend_tags,
    {
        Name = "${local.resource_name}-frontend"
    }
  )
}

module "ansible" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  
  ami = data.aws_ami.joindevops.id
  name = "${local.resource_name}-ansible"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.ansible_sg_id]
  subnet_id              = local.public_subnet_id
  user_data = file("expense.sh")

  tags = merge(
    var.common_tags,
    var.ansible_tags,
    {
        Name = "${local.resource_name}-ansible"
    }
  )
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "mysql"
      type    = "A"
      ttl     = 1
      records = [
        module.mysql.private_ip
      ]
    },
    {
      name    = "backend"
      type    = "A"
      ttl     = 1
      records = [
        module.backend.private_ip
      ]
    },
    {
      name    = "frontend"
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.private_ip
      ]
    },
    {
      name    = ""
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.public_ip
      ]
    }
  ]
}