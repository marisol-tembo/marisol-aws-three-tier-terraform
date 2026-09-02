resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Allow HTTPS from the internet to the ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "Allow traffic from ALB to application servers"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-app-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Allow MySQL from application servers only"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  description       = "HTTPS from internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_to_app" {
  type                     = "egress"
  description              = "HTTPS to application tier"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_ingress_from_alb" {
  type                     = "ingress"
  description              = "HTTPS from ALB"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "app_egress_to_rds" {
  type                     = "egress"
  description              = "MySQL to RDS"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "app_egress_https" {
  type              = "egress"
  description       = "HTTPS outbound for package updates via NAT"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_dns" {
  type              = "egress"
  description       = "DNS resolution"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "rds_ingress_from_app" {
  type                     = "ingress"
  description              = "MySQL from app tier"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "rds_egress_vpc" {
  type              = "egress"
  description       = "Outbound within VPC only"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.rds.id
}
