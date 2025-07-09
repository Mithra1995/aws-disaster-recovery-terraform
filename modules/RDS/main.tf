/*resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-sng"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier          = "${var.name_prefix}-db"

  # ── engine/size ────────────────────────────
  engine              = var.replicate_source_db == "" ? var.engine           : null
  engine_version      = var.replicate_source_db == "" ? var.engine_version   : null
  instance_class      = var.instance_class
  allocated_storage   = var.replicate_source_db == "" ? var.allocated_storage : null

  # ── authentication (writer only) ───────────
  username            = var.replicate_source_db == "" ? var.username : null
  password            = var.replicate_source_db == "" ? var.password : null

  # ── replication (reader only) ──────────────
  replicate_source_db = var.replicate_source_db != "" ? var.replicate_source_db : null

  # ── **enable backups on the writer** ───────
  backup_retention_period = var.replicate_source_db == "" ? 1 : null
  apply_immediately       = true  
  # ↑ any value ≥ 1 day is fine; 1 keeps costs minimal

  # ── networking ─────────────────────────────
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids

  skip_final_snapshot = true
}*/
