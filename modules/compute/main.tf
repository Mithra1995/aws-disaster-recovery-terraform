resource "aws_security_group" "ec2" {
  name   = "${var.name_prefix}-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_prefix}-ec2-sg"
    Environment = var.env
  }
}


#########################
# 2) Launch Template
#########################
resource "aws_launch_template" "lt" {
  name_prefix            = "${var.name_prefix}-lt-"
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]

  iam_instance_profile {
    name = var.instance_profile     # passed in
  }

  user_data = var.user_data         # already base64-encoded
}

#########################
# 3) Auto Scaling Group
#########################
resource "aws_autoscaling_group" "asg" {
  name                = "${var.name_prefix}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-ec2"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }
}

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}
