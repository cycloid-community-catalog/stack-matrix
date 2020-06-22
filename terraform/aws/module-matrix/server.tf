#
# server
#

resource "aws_security_group" "server" {
  name        = "${var.project}-${var.env}-server"
  description = "${var.project} ${var.env} matrix server"
  vpc_id      = var.vpc_id

  # http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # https
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Federation API
  ingress {
    from_port   = 8448
    to_port     = 8448
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # coturn
  ingress {
    from_port   = 3478
    to_port     = 3478
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # coturn tls
  ingress {
    from_port   = 5349
    to_port     = 5349
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # jitsi RTP media over UDP
  ingress {
    from_port   = 10000
    to_port     = 10000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # jitsi RTP media fallback over TCP
  ingress {
    from_port   = 4443
    to_port     = 4443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_tags, {
    Name = "${var.project}-${var.env}-server"
    role = "matrix"
  })
}

resource "random_shuffle" "server_subnet_id" {
  input        = var.public_subnets_ids
  result_count = 1
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.debian.id
  instance_type = var.server_type
  key_name      = var.keypair_name

  iam_instance_profile = aws_iam_instance_profile.server.name

  subnet_id              = random_shuffle.server_subnet_id.result[0]
  vpc_security_group_ids = compact(
    [
      var.bastion_sg_allow,
      aws_security_group.server.id,
      var.metrics_sg_allow,
    ],
  )

  ebs_optimized = var.server_ebs_optimized

  root_block_device {
    volume_size           = var.server_disk_size
    volume_type           = var.server_disk_type
    delete_on_termination = true
  }

  volume_tags = merge(local.merged_tags, {
      Name = "${var.project}-${var.env}-server"
      role = "matrix"
  })

  tags = merge(local.merged_tags, {
    Name = "${var.project}-${var.env}-server"
    role = "matrix"
  })
}

#
# EIP
#

resource "aws_eip" "server" {
  instance = aws_instance.server.id
  vpc      = true

  tags = merge(local.merged_tags, {
    Name = "${var.project}-${var.env}-server"
    role = "matrix"
  })
}

#
# Cloudwatch Alarms
#

resource "aws_cloudwatch_metric_alarm" "recover-server" {
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]
  alarm_description   = "Recover the instance"
  alarm_name          = "${var.project}-${var.env}-matrix-engine_recover"
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = aws_instance.server.id
  }

  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "0"
}
