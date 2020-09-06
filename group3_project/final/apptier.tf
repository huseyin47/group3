# APP_TIER

# Using standard AWS AMI for this exercise
resource "aws_launch_configuration" "group3_app_lc" {
  name_prefix     = "group3_app_lc-"
  image_id        = data.aws_ami.linux-ami-id.id
  instance_type   = var.app_lc_instance_type
  security_groups = [aws_security_group.group3_app_sg.id]
  user_data       = file("userdata.sh")
  key_name        = var.key_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "group3_app_asg" {
  max_size                  = var.asg_app_max
  min_size                  = var.asg_app_min
  health_check_grace_period = var.asg_app_grace
  health_check_type         = var.asg_app_hct
  desired_capacity          = var.asg_app_cap
  force_delete              = true
  #load_balancers            = [aws_elb.group3_app_elb.name]
  launch_configuration      = aws_launch_configuration.group3_app_lc.name
  target_group_arns = [aws_lb_target_group.alb_target_group1.arn]

  vpc_zone_identifier = [aws_subnet.group3_private3_subnet.id,
  aws_subnet.group3_private4_subnet.id]

  tag {
    key                 = "Name"
    value               = "group3_app-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "group3_app_sg" {
  name        = "group3_app_sg"
  description = "Used for frontend to backend comms"
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
resource "aws_lb" "group3_app_elb" {
  name = "group3-app-elb"
  load_balancer_type = "application"
  subnets = [aws_subnet.group3_private1_subnet.id,
  aws_subnet.group3_private2_subnet.id]
  security_groups = [aws_security_group.group3_app_sg.id]
  internal = false

  idle_timeout                = var.elb_idle_timeout

  tags = {
    name = "group3_app_elb"
  }
 
}
resource "aws_lb_target_group" "alb_target_group1" {
  name     = "alb-target-group1"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.group3_vpc.id
  tags = {
    name = "alb_target_group1"
  }
   health_check {
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
    timeout             = var.elb_timeout
    interval            = var.elb_interval
  }
  # stickiness {
  #   type            = "lb_cookie"
  #   cookie_duration = 1800
  #   enabled         = true
  # }
  
}

resource "aws_lb_listener" "alb_listener1" {
  load_balancer_arn = aws_lb.group3_app_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group1.arn
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   = aws_lb_target_group.alb_target_group1.arn
  autoscaling_group_name = aws_autoscaling_group.group3_app_asg.id
}