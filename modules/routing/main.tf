resource "aws_route_table" "public" {
  for_each = var.public_subnet_ids

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-public-${each.key}-rt"
    Tier = "public"
  }
}

resource "aws_route" "public_internet" {
  for_each = aws_route_table.public

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  for_each = var.public_subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route_table" "private" {
  for_each = var.private_subnet_ids

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-private-${each.key}-rt"
    Tier = "private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.private[each.key].id
}
