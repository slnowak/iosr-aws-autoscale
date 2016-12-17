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

resource "aws_instance" "web" {
  ami = "ami-3ee4ec29"
  instance_type = "t2.micro"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.open_ports.id}"
  ]
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

  instances = [
    "${aws_instance.web.id}"
  ]
  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 400
}

