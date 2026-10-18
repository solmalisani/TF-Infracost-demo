# App server: NO inbound rules. Admin access is through SSM Session Manager, not SSH.
resource "aws_security_group" "app" {
  name        = "${var.project}-app-sg"
  description = "App server: no inbound, access via SSM Session Manager"
  vpc_id      = aws_vpc.main.id

  # Explicit empty list: any rule added by hand in the console is reported as drift.
  ingress = []

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-app-sg" }
}

# Database: only the app server can reach it.
resource "aws_security_group" "db" {
  name        = "${var.project}-db-sg"
  description = "PostgreSQL from the app server only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from app server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = { Name = "${var.project}-db-sg" }
}
