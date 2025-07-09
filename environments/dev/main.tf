module "vpc_east" {
  source      = "../../modules/network"
  name_prefix = "east"

  vpc_cidr   = var.vpc_cidr
  pubsub     = var.east_pubsubs
  pubsub_az  = var.east_pubsub_azs
  prisub     = var.east_prisubs
  prisub_az  = var.east_prisub_azs

  enable_dns_support   = true
  enable_dns_hostnames = true
  create_nat           = var.create_nat
  nat_eip_id           = var.nat_eip_id
}

module "vpc_west" {
  source      = "../../modules/network"
  providers   = { aws = aws.west }
  name_prefix = "west"

  vpc_cidr   = var.vpc_cidr_secondary
  pubsub     = var.west_pubsubs
  pubsub_az  = var.west_pubsub_azs
  prisub     = var.west_prisubs
  prisub_az  = var.west_prisub_azs

  enable_dns_support   = true
  enable_dns_hostnames = true
  create_nat           = var.create_nat
  nat_eip_id           = var.nat_eip_id
}

# –––– 2a.  ALB (east) ––––
module "web_east_alb" {
  source              = "../../modules/alb"

  name_prefix         = "east"
  env                 = var.env

  vpc_id              = module.vpc_east.vpc_id
  subnet_ids          = module.vpc_east.public_subnet_ids

  internal            = false
  https_enabled       = var.alb_https_enabled
  ssl_policy          = var.alb_ssl_policy
  acm_certificate_arn = var.acm_certificate_arn

  //user_data = filebase64("${path.module}/userdata.sh")
}

# –––– 2b.  Compute (east) ––––
module "web_east_compute" {
  source            = "../../modules/compute"
  name_prefix       = "east"
  env               = var.env

  ami               = var.ami_east
  instance_type     = var.instance_type
  desired_capacity  = var.desired_capacity
  min_size          = var.min_size
  max_size          = var.max_size

  vpc_id            = module.vpc_east.vpc_id
  subnet_ids        = module.vpc_east.public_subnet_ids
  target_group_arn  = module.web_east_alb.tg_arn

  user_data         = filebase64("${path.module}/userdata.sh")
  instance_profile  = aws_iam_instance_profile.ec2_profile.name  # ← ADD THIS
}

# –––– 2c. ALB (west) ––––
module "web_west_alb" {
  source              = "../../modules/alb"
  providers           = { aws = aws.west }

  name_prefix         = "west"
  env                 = var.env

  vpc_id              = module.vpc_west.vpc_id
  subnet_ids          = module.vpc_west.public_subnet_ids

  internal            = false
  https_enabled       = false
  ssl_policy          = "ELBSecurityPolicy-2016-08"
  acm_certificate_arn = ""

  //user_data = filebase64("${path.module}/userdata.sh")
}

# –––– 2d. Compute (west) ––––
module "web_west_compute" {
  source            = "../../modules/compute"
  providers         = { aws = aws.west }
  name_prefix       = "west"
  env               = var.env

  ami               = var.ami_west
  instance_type     = var.instance_type
  desired_capacity  = var.desired_capacity
  min_size          = var.min_size
  max_size          = var.max_size

  vpc_id            = module.vpc_west.vpc_id
  subnet_ids        = module.vpc_west.public_subnet_ids
  target_group_arn  = module.web_west_alb.tg_arn

  user_data         = filebase64("${path.module}/userdata.sh")
  instance_profile  = aws_iam_instance_profile.ec2_profile.name  # ← ADD THIS
}

#S3
module "data" {
  source                   = "../../modules/data"
  bucket_name_prefix       = "dr-demo-use1"    
  bucket_name_prefix_secondary = "dr-demo-usw1" 
  enable_versioning  = true   
  enable_replication = true  

  providers = {
    aws.west = aws.west
  }
}
/*resource "aws_security_group" "db_east" {
  name        = "db-east-sg"
  description = "Allow traffic to RDS in east"
  vpc_id      = module.vpc_east.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_west" {
  provider    = aws.west             # <<< Add this line
  name        = "db-west-sg"
  description = "Allow traffic to RDS in west"
  vpc_id      = module.vpc_west.vpc_id  # Ensure this is correct and from the module

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##########################################
# 1. Primary – us-east-1  (writer)
##########################################
module "rds_east_primary" {
  source             = "../../modules/RDS"

  # ── identifiers ───────────────────────
  name_prefix        = "east"

  # ── engine / size ─────────────────────
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20            # GiB

  # ── auth ──────────────────────────────
  username           = var.db_master_username
  password           = var.db_master_password

  # ── networking ────────────────────────
  subnet_ids         = module.vpc_east.private_subnet_ids
  security_group_ids = [aws_security_group.db_east.id]
vpc_id = module.vpc_east.vpc_id
  #  set to empty for a primary/writer
  replicate_source_db = ""
}

##########################################
# 2. Read-replica – us-west-2
##########################################
module "rds_west_replica" {
  source             = "../../modules/RDS"
  providers          = { aws = aws.west }    

  # ── identifiers ───────────────────────
  name_prefix        = "west"
vpc_id = module.vpc_west.vpc_id
  # this tells AWS to create a cross-region read replica
  replicate_source_db = module.rds_east_primary.instance_arn
 

  # ── engine / size (must match writer) ─
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"

  # ── networking ────────────────────────
  subnet_ids         = module.vpc_west.private_subnet_ids
  security_group_ids = [aws_security_group.db_west.id]

  # still required for parameter groups etc.
  username           = var.db_master_username
  password           = var.db_master_password
  allocated_storage  = 20            # GiB
}
output "east_private_subnets_debug" {
  value = module.vpc_east.private_subnet_ids
}*/