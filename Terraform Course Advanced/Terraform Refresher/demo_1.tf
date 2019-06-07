

provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

data "aws_availability_zones" "all" {}

resource "aws_security_group" "instance" {
  name = "aws_security_instance_1"

  ingress {
    from_port = "${var.server_port}"
    to_port   = "${var.server_port}"
    protocol  = "tcp"
    # Espcifies the Access port for the Virtual Private Cloud through which the cloud is accesed
    cidr_blocks = ["0.0.0.0/0"]

  }

    # Keep the reliability of the site or the process of the deployment
  lifecycle {
    create_before_destroy = true
  }
}

# Shows Variables during the build fase of the  deployment
output "public_ip" {
  value = "${aws_instance.demo1.public_ip}"
}

# Defines a Configuration For other instances
resource "aws_lauch_configuration" "example" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  # Implmentation of the Configuration File
  launch_configuration = "${aws_launch_configuration.example.id}"
  # Defines the zone for which the instances will be available 
  availability_zones = ["${data.availability_zones.all.names}"]

  # Defines the Connection between the load balancers and the several instances of the ecs
  load_balancers = ["${aws_elb.example.name}"]
  # Tells the status of the Instance and if its unhealthy to destroy and spin up an new instance
  health_check_type = "ELB"

  # Since we are using the autoscaling instance we want to configure it so that we have a bound of instances
  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}


# Elastic Load Balancer Securty Group 
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elastic Load Balancer
resource "aws_elb" "example" {
  name = "terraform-asg-example"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.elb.id}"]

 # Load Balancer Listening Ports to Forward Requests
  listener {
      lb_port = 80
      lb_port = "http"
      instance_port = "${var.server_port}"
      instance_protocol = "http"
  }

  # Defines how the health checks shall occur
  health_check {
      healthy_threshold = 2
      # If the status of the health check is unhealthy it will stop sending requests
      unhealthy_threshold = 2
      timeout = 3
      internal = 30 
      # Sends an HTTP request every 30 seconds with a timout of 3 seconds
      target = "HTTP:${var.server_port}/"
  }
}



resource "aws_instance" "demo1" {
  # ami service definition of already defined containers
  ami                    = "ami-40d28157"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]


  # nohup and busyboc defines a virtual server that wil host the site of index.html
  user_data = <<EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  tags = {
    Name = "Terraform Example"
  }

  lifecycle {
    create_before_destroy = true
  }

}

