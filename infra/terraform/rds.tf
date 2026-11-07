resource "aws_security_group" "rds" {
  name        = "${var.nombre}-rds"
  description = "Postgres solo desde las subredes de los nodos"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL desde subredes publicas (nodos EKS)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = aws_subnet.publica[*].cidr_block
  }

  tags = { Name = "${var.nombre}-rds" }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.nombre}-db"
  subnet_ids = aws_subnet.privada[*].id
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.nombre}-pg"
  engine         = "postgres"
  engine_version = "18"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name                     = "labdevops"
  username                    = "labadmin"
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period    = 1
  auto_minor_version_upgrade = true
  apply_immediately          = true
  deletion_protection        = false
  skip_final_snapshot        = true
}
