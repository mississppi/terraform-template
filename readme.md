# VPC Configuration

| Resource       | Property                       | Value                  |
| -------------- | ------------------------------ | ---------------------- |
| `aws_vpc`      | `cidr_block`                   | `10.0.0.0/16`          |
|                | `enable_dns_support`           | `true`                 |
|                | `enable_dns_hostnames`         | `true`                 |
|                | `tags.Name`                    | `main-vpc`             |

# Subnet Configuration

| Resource              | Property                        | Value                  |
| --------------------- | ------------------------------- | ---------------------- |
| `aws_subnet.public_1a` | `vpc_id`                        | `aws_vpc.main.id`      |
|                       | `cidr_block`                    | `10.0.1.0/24`          |
|                       | `availability_zone`             | `ap-northeast-1a`      |
|                       | `map_public_ip_on_launch`       | `true`                 |
|                       | `tags.Name`                     | `public-subnet-1a`     |
| `aws_subnet.private_1a`| `vpc_id`                        | `aws_vpc.main.id`      |
|                       | `cidr_block`                    | `10.0.2.0/24`          |
|                       | `availability_zone`             | `ap-northeast-1a`      |
|                       | `tags.Name`                     | `private-subnet-1a`    |
| `aws_subnet.public_1c` | `vpc_id`                        | `aws_vpc.main.id`      |
|                       | `cidr_block`                    | `10.0.3.0/24`          |
|                       | `availability_zone`             | `ap-northeast-1c`      |
|                       | `map_public_ip_on_launch`       | `true`                 |
|                       | `tags.Name`                     | `public-subnet-1c`     |
| `aws_subnet.private_1c`| `vpc_id`                        | `aws_vpc.main.id`      |
|                       | `cidr_block`                    | `10.0.4.0/24`          |
|                       | `availability_zone`             | `ap-northeast-1c`      |
|                       | `tags.Name`                     | `private-subnet-1c`    |

# Route Table Configuration

| Resource                 | Property        | Value                        |
| ------------------------ | --------------- | ---------------------------- |
| `aws_route_table.public`  | `vpc_id`        | `aws_vpc.main.id`            |
|                          | `tags.Name`     | `public-route-table`         |
| `aws_route_table.private` | `vpc_id`        | `aws_vpc.main.id`            |
|                          | `tags.Name`     | `private-route-table`        |

# IGW Configuration

| Resource                 | Property        | Value                        |
| ------------------------ | --------------- | ---------------------------- |
| `aws_internet_gateway.igw`| `vpc_id`        | `aws_vpc.main.id`            |
|                          | `tags.Name`     | `main-igw`                   |

# Route for Public Subnet via Internet Gateway

| Resource               | Property                    | Value                |
| ---------------------- | --------------------------- | -------------------- |
| `aws_route.public_to_igw`| `route_table_id`            | `aws_route_table.public.id` |
|                         | `destination_cidr_block`    | `0.0.0.0/0`          |
|                         | `gateway_id`                | `aws_internet_gateway.igw.id` |

# NAT Gateway Configuration

| Resource            | Property                       | Value                   |
| ------------------- | ------------------------------ | ----------------------- |
| `aws_eip.nat_eip`   | `vpc`                          | `true`                  |
|                     | `tags.Name`                    | `nat-eip`               |
| `aws_nat_gateway.nat`| `allocation_id`                | `aws_eip.nat_eip.id`    |
|                     | `subnet_id`                    | `aws_subnet.public_subnet_1c.id` |
|                     | `tags.Name`                    | `nat-gateway`           |

# Route for Private Subnet via NAT Gateway

| Resource               | Property                    | Value                |
| ---------------------- | --------------------------- | -------------------- |
| `aws_route.private_to_nat`| `route_table_id`           | `aws_route_table.private.id` |
|                         | `destination_cidr_block`    | `0.0.0.0/0`          |
|                         | `nat_gateway_id`            | `aws_nat_gateway.nat.id` |

# Security Group Configuration

| Resource                | Property         | Value                    |
| ----------------------- | ---------------- | ------------------------ |
| `aws_security_group.public_sg` | `vpc_id`   | `aws_vpc.main.id`        |
|                          | `tags.Name`      | `public-sg`              |
|                          | `ingress`        | `Allow SSH, HTTP, HTTPS` |
|                          | `egress`          | `Allow all outbound traffic` |
| `aws_security_group.private_sg`| `vpc_id`   | `aws_vpc.main.id`        |
|                          | `tags.Name`      | `private-sg`             |
|                          | `ingress`        | `Allow traffic from public subnet` |
|                          | `egress`          | `Allow all outbound traffic` |
| `aws_security_group.alb_sg`| `vpc_id`       | `aws_vpc.main.id`        |
|                          | `tags.Name`      | `alb-sg`                 |
|                          | `ingress`        | `Allow HTTP, HTTPS`      |
|                          | `egress`          | `Allow all outbound traffic` |

# RDS Security Group Configuration

| Resource               | Property                       | Value                |
| ---------------------- | ------------------------------ | -------------------- |
| `aws_security_group.rds_sg` | `vpc_id`                      | `aws_vpc.main.id`    |
|                          | `tags.Name`                    | `rds-sg`             |
|                          | `ingress`                      | `Allow MySQL access from private subnet instances` |
|                          | `egress`                       | `Allow all outbound traffic` |

# Target Group

| Resource                  | Property        | Value                |
| ------------------------- | --------------- | -------------------- |
| `aws_lb_target_group.web_tg` | `name`         | `web-target-group`   |
|                           | `port`          | `80`                 |
|                           | `protocol`      | `HTTP`               |
|                           | `vpc_id`        | `aws_vpc.main.id`    |
