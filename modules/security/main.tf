resource "aws_security_group" "internal_https" {
  name_prefix = "${var.name_prefix}-internal-https-"
  description = "Example workload group allowing HTTPS only from inside the VPC"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-internal-https"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal_https" {
  security_group_id = aws_security_group.internal_https.id
  description       = "HTTPS from within the VPC"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Intentional reference risk: IPv4 destinations are unrestricted, but the
# protocol and port remain constrained to TCP 443. Production designs should
# replace this with approved prefix lists, VPC endpoints, or proxy destinations.
#trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "internal_https_outbound" {
  security_group_id = aws_security_group.internal_https.id
  description       = "HTTPS egress for updates and managed service APIs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_security_group" "outbound_https" {
  name_prefix = "${var.name_prefix}-outbound-https-"
  description = "Example client group with no ingress and HTTPS-only egress"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-outbound-https"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Intentional reference risk: IPv4 destinations are unrestricted, but the
# protocol and port remain constrained to TCP 443. Production designs should
# replace this with approved prefix lists, VPC endpoints, or proxy destinations.
#trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "outbound_https" {
  security_group_id = aws_security_group.outbound_https.id
  description       = "HTTPS egress for managed service APIs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
