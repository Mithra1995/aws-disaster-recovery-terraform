####################
# 1. Security Group
####################
 ############################
# 1. Security Group
############################
resource "aws_security_group" "alb" {
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name        = "${var.name_prefix}-alb-sg"
    Environment = var.env
  }
}


####################
# 2. Target Group
####################
resource "aws_lb_target_group" "tg" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
  path     = "/"
  protocol = "HTTP"
  matcher  = "200"
}
  tags = { Name = "${var.name_prefix}-tg" }
}

####################
# 3. Load-Balancer
####################
resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb.id]
}

####################
# 4. Listeners
####################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
  type             = "forward"
  target_group_arn = aws_lb_target_group.tg.arn
}
}

resource "aws_lb_listener" "https" {
  count             = var.https_enabled ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
 certificate_arn = var.acm_certificate_arn
 default_action {
  type             = "forward"
  target_group_arn = aws_lb_target_group.tg.arn
}
}

####################
# 5. (Optional) userdata file on bucket / etc
####################
/*resource "null_resource" "dummy_userdata" {
  count    = var.user_data == "" ? 0 : 1
  provisioner "local-exec" {
    command = "echo '${base64encode(var.user_data)}' > /dev/null"
  }
}*/
