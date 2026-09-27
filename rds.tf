resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp2" # Sandbox template only permits gp2 — gp3 is blocked by the org SCP

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = false # Single-AZ, per Fontys AWS org SCP restrictions
  publicly_accessible = false # REQ-NCA-P1-02: never exposed to the public internet

  storage_encrypted       = true # required by org SCP — the AWS console enables this by default, Terraform does not
  backup_retention_period = 7    # common org guardrail requirement; 0 (disabled) is often blocked by SCP

  skip_final_snapshot = true # set to false + provide final_snapshot_identifier for a real production setup

  tags = {
    Name = "${var.project_name}-db"
  }
}
