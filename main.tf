module "network" {
  source = "./network" # networkディレクトリをモジュールとして呼び出す
}

module "server" {
  source = "./server"
  subnet_id       = module.network.public_subnet_id[0]
  security_group_id = module.network.public_sg_id
}

module "alb" {
  source = "./alb"
  vpc_id = module.network.vpc_id
  example_id = module.server.instance_id
  subnet_ids       = module.network.public_subnet_ids
  security_group_id = module.network.public_sg_id
}

/*
module "database" {
  source = "./database" # databaseディレクトリをモジュールとして呼び出す
  rds_sg_id         = module.network.rds_sg_id       # セキュリティグループID
  private_subnet_ids = module.network.private_subnet_ids # プライベートサブネットIDのリスト
  db_subnet_group    = "rds-subnet-group"             # サブネットグループ名
}
*/