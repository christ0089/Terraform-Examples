

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "demo1" {
    # ami service definition
    ami = "aws12332"
    instance-type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_instance.instance.id}"]
    

    # nohup and busyboc defines a virtual server that wil host the site of index.html
    user_data = <<EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
    tags = {
        Name = "Terraform Example"
    }
}

resource "aws_security_group" "instanct" {
    name = "aws_security_instance"
    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        # Espcifies the Access port for the Virtual Private Cloud through which the cloud is accesed
        cidr_blocks = ["0.0.0.0/0"]
    }
}

