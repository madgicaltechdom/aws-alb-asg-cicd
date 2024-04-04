locals {
  current_time = timeadd(timestamp(), "5h30m") // Adding 5 hours and 30 minutes to UTC to get IST
  timestamp    = formatdate("YYYY-MM-DD/HH-mm-ss", local.current_time)
}

resource "aws_ami_from_instance" "instance" {
  name                    = "${var.ami_name} (${local.timestamp})"
  source_instance_id      = var.instance_id
  snapshot_without_reboot = true

  lifecycle {
    create_before_destroy = true
  }
}

output "aws_ami_from_instance" {
  value = aws_ami_from_instance.instance.id
}


# Create a security group for the ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.alb_name_prefix}-sg"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP, HTTPS and SSH traffic
  ingress {
    description = "Allow HTTP inbound traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS inbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH inbound traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to all destinations
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = var.alb_name_prefix
  internal           = false
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.alb_name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

# Create a listener for the ALB
resource "aws_lb_listener" "app_listener_http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_listener" "app_listener_https" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443 # HTTPS port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Use an appropriate SSL policy

  certificate_arn = var.acm_certificate_arn # Use the ACM certificate ARN from variables

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Create a Launch Template for the EC2 instances
resource "aws_launch_template" "launch_template" {
  name_prefix = "${var.alb_name_prefix}-lt"

  image_id      = aws_ami_from_instance.instance.id
  instance_type = var.instance_type
  key_name      = var.instance_keypair


  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.private_subnet_2.id
    security_groups             = [aws_security_group.alb_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda" # Use the correct root device name
    ebs {
      volume_type           = "gp3"
      delete_on_termination = true # This will delete the volume on instance termination
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.alb_name_prefix}-lt" # Name for the EC2 instances
    }
  }

  iam_instance_profile {
    arn = var.iam_role_arn
  }

  user_data = base64encode(<<EOT
#!/bin/bash
# Add user data script here
    EOT
  )
}

# Create an Auto Scaling Group using the Launch Template
resource "aws_autoscaling_group" "app_asg" {
  name = "${var.alb_name_prefix}-asg"
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  vpc_zone_identifier = [aws_subnet.private_subnet_2.id]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
    triggers = ["tag"]
  }
}

resource "null_resource" "wait_for_refresh" {
  triggers = {
    id      = aws_autoscaling_group.app_asg.launch_template[0].id
    version = aws_autoscaling_group.app_asg.launch_template[0].version
    tag     = join(",", [for key, value in aws_autoscaling_group.app_asg.tag : "${key}=${value}"])
  }

  provisioner "local-exec" {
    command = <<-EOT
      python3 -m pip install boto3
      python3 checkout.py
    EOT

    environment = {
      ASG_NAME = aws_autoscaling_group.app_asg.name
    }
  }
}

