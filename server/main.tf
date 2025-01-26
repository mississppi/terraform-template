provider "aws" {
  region = "ap-northeast-1"
}

# ネットワークリソースの情報を取得
data "terraform_remote_state" "network" {
  backend = "local"

  # networkディレクトリのstateファイルへのパスを指定
  config = {
    path = "../network/terraform.tfstate"
  }
}

# EC2インスタンスの作成
resource "aws_instance" "example" {
  ami           = "ami-0fb04413c9de69305"
  instance_type = "t2.micro"
  key_name      = "mississippi-ec2"
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_id
  security_groups = [data.terraform_remote_state.network.outputs.public_sg_id]

  tags = {
    Name = "ExampleInstance"
  }
}