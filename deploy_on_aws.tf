provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "${file("insecure-deployer.pub")}"
}

resource "aws_security_group" "open_ports" {
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami = "ami-06c4cb11"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "${aws_key_pair.deployer.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.open_ports.id}"]

  provisioner "file" {
    source = "target/iosr-aws-autoscale-1.0-SNAPSHOT.jar"
    destination = "/tmp/app.jar",
    connection {
      type = "ssh",
      user = "ubuntu",
      private_key = "${file("insecure-deployer")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y openjdk-8-jdk",
      "nohup java -jar /tmp/app.jar &",
      "sleep 2"
    ],
    connection {
      type = "ssh",
      user = "ubuntu",
      private_key = "${file("insecure-deployer")}"
    }
  }
}
