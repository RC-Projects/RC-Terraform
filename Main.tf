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
  tags = { Name = "Web_Server" }
  #Security group plus SSH key
  security_groups = ["admin-group1"]
  connection {
    type        = "ssh"
    user        = "ec2-user" // ec2-user for AWS Linux | ubuntu for Ubuntu
    private_key = file("~/.ssh/admin-aws.pem")
    host        = self.public_ip
  }

  #Run updates and installs web server packages 
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install htop -y",
      "sudo mkdir /software",
      "sudo chown ec2-user:ec2-user /software",
      #"sudo yum install golang.x86_64 -y",
      "sudo amazon-linux-extras install -y php7.2",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo touch /var/www/html/index.html" // Replace with content
    ]
  }

  #Push test script to server
  provisioner "file" {
    source      = "PushMe.sh"
    destination = "/software/PushMe.sh"
  }

  #Push logo to server
  provisioner "file" {
    source      = "push/logo.png"
    destination = "/software/logo.png"
  }

  #Push index page
  provisioner "file" {
    source      = "push/index.html"
    destination = "/software/index"

  }

  #Append data to log
  provisioner "file" {
    content     = "ami used: ${self.ami}"
    destination = "/software/file.log"
  }

  #Update file permisions and move filse to web directory
  provisioner "remote-exec" {
    inline = ["sudo chmod 740 /software/PushMe.sh",
      "sudo sed -i -e 's/\r$//' /softare/PushMe.sh", // Purge any bad windows formatting. 
      "sudo mv /software/logo.png /var/www/html/logo.png"
    ]
  }
}
#### End of main code ####


#Assign EIP
resource "aws_eip" "vpn" {
  vpc      = true
  instance = "${aws_instance.Eg_Deploy.id}"
  lifecycle {
    prevent_destroy = true
  }
}


#Print Public DNS on Finish
output "public_dns" {
  value = "${aws_instance.Eg_Deploy.public_dns}"
}


