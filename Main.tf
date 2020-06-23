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
  tags = { Name = "TF_init" }
  #Security group plus SSH key
  security_groups = ["admin-group1"]
  connection {
    type        = "ssh"
    user        = "ec2-user"               // for AWS Linux
    private_key = file("~/.ssh/myKey.pem") // your key here
    host        = self.public_ip
  }

  #Run init shell commands / software updates and installs
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install htop -y",
      "sudo mkdir /software",
      "sudo chown ec2-user:ec2-user /software"
    ]
  }

  #Push File to Server
  provisioner "file" {
    source      = "PushMe.sh"
    destination = "/software/PushMe.sh"
  }

  #Append data to log
  provisioner "file" {
    content     = "ami used: ${self.ami}"
    destination = "/software/file.log"
  }

  #Update file permisions 
  provisioner "remote-exec" {
    inline = ["sudo chmod 740 /software/PushMe.sh"]
  }
  #End of main code
}

#Print Public DNS on Finish
output "public_dns" {
  value = "${aws_instance.Eg_Deploy.public_dns}"
}
