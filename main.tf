module "network" {
  source = "./network" # networkディレクトリをモジュールとして呼び出す
}

/*
module "database" {
  source = "./database" # databaseディレクトリをモジュールとして呼び出す
  rds_sg_id         = module.network.rds_sg_id       # セキュリティグループID
  private_subnet_ids = module.network.private_subnet_ids # プライベートサブネットIDのリスト
  db_subnet_group    = "rds-subnet-group"             # サブネットグループ名
}
*/