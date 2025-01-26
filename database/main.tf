resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 20                      # ストレージ容量（GB）
  engine               = "mysql"                # データベースエンジン
  engine_version       = "8.0"                  # MySQLバージョン
  instance_class       = "db.t3.micro"          # インスタンスのサイズ
  db_name                 = var.db_name            # データベース名
  username             = var.db_username       # 管理ユーザー名
  password             = var.db_password        # 管理ユーザーパスワード
  parameter_group_name = "default.mysql8.0"     # パラメータグループ
  publicly_accessible  = false                  # 外部からのアクセスを許可しない
  skip_final_snapshot  = true                   # 削除時のスナップショットをスキップ
  vpc_security_group_ids = var.rds_sg_id      # RDS用セキュリティグループ
  db_subnet_group_name   = var.db_subnet_group  # サブネットグループ
}

# サブネットグループの定義
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group
  subnet_ids = var.private_subnet_ids           # プライベートサブネットを使用
  tags = {
    Name = "rds-subnet-group"
  }
}
