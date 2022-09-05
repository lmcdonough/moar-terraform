##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_networking_bucket" {
    default = "ddt-networking"
}
variable "aws_application_bucket" {
    default = "ddt-application"
}
variable "aws_dynamodb_table" {
    default = "ddt-tfstatelock"
}
variable "user_home_path" {"/Users/levi"}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

##################################################################################
# RESOURCES
##################################################################################
resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.aws_dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "ddtnet" {
  bucket = "${var.aws_networking_bucket}"
  acl    = "private"
  force_destroy = true
  
  versioning {
    enabled = true
  }

      policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforAppTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.jonny.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.aws_networking_bucket}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.levi.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_networking_bucket}",
                "arn:aws:s3:::${var.aws_networking_bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "ddtapp" {
  bucket = "${var.aws_application_bucket}"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
        policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforNetTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.levi.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.aws_application_bucket}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.levi.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_application_bucket}",
                "arn:aws:s3:::${var.aws_application_bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin-attach" {
  group      = "${aws_iam_group.ec2admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user" "levi" {
  name = "levi"
}

resource "aws_iam_user_policy" "levi_rw" {
    name = "levi"
    user = "${aws_iam_user.levi.name}"
    policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_application_bucket}",
                "arn:aws:s3:::${var.aws_application_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_user" "jonny" {
    name = "jonny"
}

resource "aws_iam_access_key" "levi" {
    user = "${aws_iam_user.levi.name}"
}

resource "aws_iam_user_policy" "networking_admin_s3_policy" {
    name = "networking_admin_s3_policy"
    user = "${aws_iam_user.levi.name}"
   policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_networking_bucket}",
                "arn:aws:s3:::${var.aws_networking_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_access_key" "levi" {
    user = "${aws_iam_user.levi.name}"
}

resource "aws_iam_group_membership" "add-ec2admin" {
  name = "add-ec2admin"

  users = [
    "${aws_iam_user.levi.name}",
  ]

  group = "${aws_iam_group.ec2admin.name}"
}

resource "local_file" "aws_keys" {
    content = <<EOF
/* 
[default]
aws_access_key_id = ${var.aws_access_key}
aws_secret_access_key = ${var.aws_secret_key}

[levi]
aws_access_key_id = ${aws_iam_access_key.levi.id}
aws_secret_access_key = ${aws_iam_access_key.levi.secret}

[jonny]
aws_access_key_id = ${aws_iam_access_key.jonny.id}
aws_secret_access_key = ${aws_iam_access_key.jonny.secret} */

EOF
    filename = "${var.user_home_path}/.aws/credentials"

}

##################################################################################
# OUTPUT
##################################################################################

output "levi-access-key" {
    value = "${aws_iam_access_key.levi.id}"
}

output "levi-secret-key" {
    value = "${aws_iam_access_key.levi.secret}"
}

output "jonny-access-key" {
    value = "${aws_iam_access_key.jonny.id}"
}

output "jonny-secret-key" {
    value = "${aws_iam_access_key.jonny.secret}"
}