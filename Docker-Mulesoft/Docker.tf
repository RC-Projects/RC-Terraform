#Main TF Script

provider "aws" {
  profile = "default"
  region  = var.region // defined in terraform.tfvars | configured in variagbles.tf
}

resource "aws_instance" "Eg_Deploy" {
  ami           = var.ami // defined in terraform.tfvars | configured in variagbles.tf
  instance_type = "t2.micro"
  key_name      = "admin-aws"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  #Instance Name
  tags = { Name = "Docker_Server" }
  #Security group plus SSH key
  security_groups = ["admin-group1"]
  connection {
    type        = "ssh"
    user        = "ec2-user"                   // ec2-user for AWS Linux | ubuntu for Ubuntu
    private_key = file("~/.ssh/admin-aws.pem") // your key here
    host        = self.public_ip
  }

  #Run software updates and installs
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user"
    ]
  }

  #Push dockerfile to server
  provisioner "file" {
    source      = "Dockerfile"
    destination = "/home/ec2-user/Dockerfile"
  }

  #Push start docker script to server
  provisioner "file" {
    source      = "run_docker_image.sh"
    destination = "/home/ec2-user/run_docker_image.sh"
  }

  #Create Mule Container and run start script. 
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/run_docker_image.sh",
      "sudo sh run_docker_image.sh"
    ]
  }
  #### End of main code ####
}

#Print Public DNS on Finish
output "public_dns" {
  value = "${aws_instance.Eg_Deploy.public_dns}"
}
