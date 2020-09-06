# WEB_TIER
# Using standard AWS AMI for tnis exercise
resource "aws_launch_configuration" "group3_web_lc" {
  name_prefix          = "group3_web_lc"
  image_id             = data.aws_ami.linux-ami-id.id
  instance_type        = var.web_lc_instance_type
  #iam_instance_profile = "aws_iam_instance_profile.ec2_instance_profile.name"
  security_groups      = [aws_security_group.group3_web_sg.id]
  user_data            = file("userdata.sh")
  key_name             = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "group3_web_asg" {
  max_size                  = var.asg_web_max
  min_size                  = var.asg_web_min
  health_check_grace_period = var.asg_web_grace
  health_check_type         = var.asg_web_hct
  desired_capacity          = var.asg_web_cap
  force_delete              = true
  #load_balancers            = [aws_lb.group3_web_elb.name]
  launch_configuration      = aws_launch_configuration.group3_web_lc.name
  target_group_arns = [aws_lb_target_group.alb_target_group.arn]
  vpc_zone_identifier = [aws_subnet.group3_private1_subnet.id,
  aws_subnet.group3_private2_subnet.id]

  tag {
    key                 = "Name"
    value               = "group3_web_asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "group3_web_sg" {
  name        = "group3_web_sg"
  description = "Used by ELB for public access to web servers"
  vpc_id      = aws_vpc.group3_vpc.id

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
}
resource "aws_lb" "group3_web_elb" {
  name = "group3-web-elb"
  load_balancer_type = "application"
  internal = false
  subnets = [aws_subnet.group3_public1_subnet.id,
  aws_subnet.group3_public2_subnet.id]
  security_groups = [aws_security_group.group3_web_sg.id]
  idle_timeout                = var.elb_timeout
  
  tags = {
    name = "group3_web_elb"
  }
}
resource "aws_lb_target_group" "alb_target_group" {
  name     = "alb-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.group3_vpc.id
  tags = {
    name = "alb_target_group"
  }
  health_check {
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
    timeout             = var.elb_timeout
    interval            = var.elb_interval
   }
}
  # stickiness {
  #   type            = "lb_cookie"
  #   cookie_duration = 1800
  #   enabled         = true
  # }
  
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.group3_web_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "group3_web_asg" {
  alb_target_group_arn   = aws_lb_target_group.alb_target_group.arn
  autoscaling_group_name = aws_autoscaling_group.group3_web_asg.id
}

# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "EC2-IAM-Instance-Profile"
#   role = "aws_iam_role.ec2_iam_role.name"
#}