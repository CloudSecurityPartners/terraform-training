# Configure the Terraform backend to store state in S3
terraform {
  backend "s3" {
    bucket = "hackgdl-2025"
    key    = "terraform/state/ec2-instance.tfstate"
    region = "us-east-1"
    # Uncomment if you need DynamoDB state locking
    # dynamodb_table = "terraform-lock"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a security group for the EC2 instance
resource "aws_security_group" "instance_sg" {
  name        = "instance-security-group"
  description = "Security group for EC2 instance"

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
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

  tags = {
    Name = "instance-security-group"
  }
}

# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-05b10e08d247fb927" # Amazon Linux 2 AMI (adjust for your region)
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  
  # Optional: Add a key pair for SSH access
  # key_name = "your-key-pair-name"
  
  tags = {
    Name = "WebServer"
    Environment = "Development"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
  description = "The public IP address of the web server"
}