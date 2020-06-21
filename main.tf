//Setting up discovered defaults
resource "random_pet" "default" {
  length = 2
}

data "http" "user_ip" {
  url = "http://ipv4.icanhazip.com"
}

//  The latest Amazon Linux 2 AMI.
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  default_for_az    = true
  availability_zone = var.availability_zone == null ? "${data.aws_region.current.name}a" : var.availability_zone
}


//  A keypair for SSH access to the instances.
resource "aws_key_pair" "keypair" {
  key_name   = var.instance_name
  public_key = file(var.public_key_path)
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name == null ? random_pet.default.id : var.bucket_name
  acl    = "private"
}

//Block all other access to this bucket other than the specified role.
resource "aws_s3_bucket_policy" "allowrole" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
          "AWS" : "${aws_iam_role.role.arn}"
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}",
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "access_bucket" {
  name = random_pet.default.id
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "${aws_s3_bucket.bucket.id}_access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "policy" {
  name        = random_pet.default.id
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}",
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "access_bucket" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id == null ? data.aws_vpc.default.id : var.vpc_id

  ingress {
    description = "SSH from Current Public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.user_ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test" {
  ami                         = var.ami == null ? data.aws_ami.amazon_linux2.id : var.ami
  iam_instance_profile        = aws_iam_instance_profile.access_bucket.name
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.keypair.key_name
  subnet_id                   = var.subnet_id == null ? data.aws_subnet.default.id : var.subnet_id
  associate_public_ip_address = var.make_public
  security_groups             = [aws_security_group.allow_ssh.id]

  tags = {
    Name        = var.instance_name == null ? random_pet.default.id : var.instance_name
    Environment = var.environment
  }
}

