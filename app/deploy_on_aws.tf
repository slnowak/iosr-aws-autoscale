provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "open_ports" {
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_elb" "balancer" {
  availability_zones = [
    "us-east-1b"
  ]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/health"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 400
}

resource "aws_autoscaling_group" "web-asg" {
  availability_zones   = ["us-east-1b"]
  name                 = "terraform-example-asg"
  max_size             = "8"
  min_size             = "1"
  desired_capacity     = "2"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.autoscaling_conf.name}"
  load_balancers       = ["${aws_elb.balancer.name}"]
}

resource "aws_launch_configuration" "autoscaling_conf" {
  image_id = "ami-7c3b306b"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.open_ports.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "app-scale-up" {
  name = "app-scale-up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
}

resource "aws_autoscaling_policy" "app-scale-down" {
  name = "app-scale-down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name = "high-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "60"
  alarm_description = "This metric monitors ec2 cpu for high utilization on app hosts"
  alarm_actions = [
    "${aws_autoscaling_policy.app-scale-up.arn}"
  ]
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web-asg.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name = "low-cpu-usage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "40"
  alarm_description = "This metric monitors ec2 cpu for low utilization on app hosts"
  alarm_actions = [
    "${aws_autoscaling_policy.app-scale-down.arn}"
  ]
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web-asg.name}"
  }
}