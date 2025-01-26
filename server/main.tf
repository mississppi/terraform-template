provider "aws" {
  region = "ap-northeast-1"
}

# EC2インスタンスの作成
resource "aws_instance" "example" {
  ami           = "ami-0fb04413c9de69305"
  instance_type = "t2.micro"
  key_name      = "mississippi-ec2"
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id] 

  tags = {
    Name = "ExampleInstance"
  }
}