# main.tf

# Configure the provider (using AWS as an example)
provider "aws" {
  region = "us-east-1"
}

# Create a security group that allows SSH and custom port for netcat
resource "aws_security_group" "netcat_sg" {
  name        = "netcat-security-group"
  description = "Allow SSH and netcat ports"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Netcat listener port
  ingress {
    from_port   = 4444
    to_port     = 4444
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instance
resource "aws_instance" "netcat_server" {
  ami           = "ami-05b10e08d247fb927" # Ubuntu 20.04 LTS (replace with appropriate AMI for your region)
  instance_type = "t2.micro"
  key_name      = "hackgdl" # Replace with your SSH key pair name

  security_groups = [aws_security_group.netcat_sg.name]

  tags = {
    Name = "NetcatServer"
  }

  # Connection details for the remote-exec provisioner
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./hackgdl.pem") # Path to your private key
    host        = self.public_ip
  }

  # Install netcat if not present and start listener
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nc", 
      "echo 'Starting netcat listener on port 4444'",
      "nohup bash -c 'while true; do nc -lvnp 4444 -e /bin/bash; done' > /tmp/nc_output.txt 2>&1 &",
      "sleep 2", # Give it a moment to start
    ]
  }
}

# Output the public IP so you can connect to the netcat server
output "netcat_server_ip" {
  value = aws_instance.netcat_server.public_ip
  description = "The public IP address of the netcat server"
}

# To connect to the netcat listener from another machine:
# nc <server_ip> 4444