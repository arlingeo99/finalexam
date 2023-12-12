resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "database-subnet-group"
  subnet_ids = [var.vpc_public_subnet_1_id, var.vpc_public_subnet_2_id]
  tags = {
    Name = "Database subnet group"
  }
}

# Create RDS instance
resource "aws_db_instance" "main" {
  identifier             = var.db_name
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.db_size
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = true
  depends_on             = [aws_security_group.db_security_group]
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot    = true
  apply_immediately      = true
}

# Create a security group
resource "aws_security_group" "db_security_group" {
  vpc_id = var.vpc_id

  # Example rule allowing inbound MYSQL traffic
  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "db_security_group"
  }
}
