

# matrix A
# <IP>
resource "aws_route53_record" "matrix" {
    count   = var.create_route53_records ? 1 : 0
    zone_id = var.route53_zone_id
    name    = "matrix"
    type    = "A"
    ttl     = "3600"
    records = [aws_eip.server.public_ip]
}

# element CNAME
# matrix.cycloid.io
resource "aws_route53_record" "element" {
    count   = var.create_route53_records ? 1 : 0
    zone_id = var.route53_zone_id
    name    = "element"
    type    = "CNAME"
    ttl     = "3600"
    records = [aws_route53_record.matrix[0].fqdn]
}

# dimension CNAME
# matrix.cycloid.io
resource "aws_route53_record" "dimension" {
    count   = var.create_route53_records ? 1 : 0
    zone_id = var.route53_zone_id
    name    = "dimension"
    type    = "CNAME"
    ttl     = "3600"
    records = [aws_route53_record.matrix[0].fqdn]
}

# jitsi CNAME
# matrix.cycloid.io
resource "aws_route53_record" "jitsi" {
    count   = var.create_route53_records ? 1 : 0
    zone_id = var.route53_zone_id
    name    = "jitsi"
    type    = "CNAME"
    ttl     = "3600"
    records = [aws_route53_record.matrix[0].fqdn]
}

# _matrix-identity._tcp SRV
# 10 0 443 matrix.cycloid.io
resource "aws_route53_record" "identity" {
    count   = var.create_route53_records ? 1 : 0
    zone_id = var.route53_zone_id
    name    = "_matrix-identity._tcp"
    type    = "SRV"
    ttl     = "3600"
    records = ["10 0 443 ${aws_route53_record.matrix[0].fqdn}"]
}

# # _matrix._tcp SRV
# # 10 0 8448 matrix.cycloid.io
# resource "aws_route53_record" "delegation" {
#     count   = var.create_route53_records ? 1 : 0
#     zone_id = var.route53_zone_id
#     name    = "_matrix._tcp"
#     type    = "SRV"
#     ttl     = "3600"
#     records = ["10 0 8448 ${aws_route53_record.matrix[0].fqdn}"]
# }
