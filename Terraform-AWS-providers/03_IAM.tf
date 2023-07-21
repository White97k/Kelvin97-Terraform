##### Create AWS IAM Role #####
resource "aws_iam_role" "codedeploy_role" {
  name               = "codedeploy"
  description        = "Role for CodeDeploy Service"
  assume_role_policy = file("IAM/codedeploy_assume_role_policy.json")

  tags = {
    Name = "codedeploy"
    Environment = var.account
  }
}

resource "aws_iam_role" "ec2codedeploy_role" {
  name               = "ec2codedeploy"
  description        = "Allows EC2 instances to call AWS services on your behalf"
  assume_role_policy = file("IAM/ec2codedeploy_assume_role_policy.json")

  tags = {
    Name = "ec2codedeploy"
    Environment = var.account
  }
}

##### Create Inline Policy #####
resource "aws_iam_role_policy" "role_policy" {
  name   = "for-awsoper-role-passing"
  role   = aws_iam_role.ec2codedeploy_role.id
  policy = file("IAM/for-awsoper-role-passing.json")
}

##### Create IAM Policy #####
resource "aws_iam_policy" "policy_dba-policy" {
  name                        = "dba-policy"
  description                 = "For DBA Support"
  policy                      = file("IAM/dba_policy.json")
}

resource "aws_iam_policy" "policy_prodsupport-policy" {
  name                        = "prodsupport-policy"
  description                 = "For Production Support"
  policy                      = file("IAM/prodsupport_policy.json")
}

resource "aws_iam_policy" "policy_inline_cloudtrail_graylog-policy" {
  name                        = "cloudtrail_graylog-policy"
  description                 = "For cloudtrail logs to stream to graylog in security dept"
  policy                      = file("IAM/cloudtrail_graylog_policy.json")
}

##### Create AWS IAM Users #####
resource "aws_iam_user" "user" {
  for_each = toset([
    "grafana",
    "codedeploy",
    "cloudtrail"
  ])
  name = each.key
}

##### Attach Policy to Users & Roles #####
resource "aws_iam_policy_attachment" "codedeploy_role_attach" {
  name = aws_iam_role.codedeploy_role.name
  roles      = [aws_iam_role.codedeploy_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_policy_attachment" "ec2codedeploy_attach" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
  ])

  name = aws_iam_role.ec2codedeploy_role.name
  roles      = [aws_iam_role.ec2codedeploy_role.name]
  policy_arn = each.value
}

resource "aws_iam_policy_attachment" "codedeploy_user_attach" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
  ])
  name  = aws_iam_user.user["codedeploy"].name
  users = [aws_iam_user.user["codedeploy"].name]
  policy_arn = each.value
}

resource "aws_iam_policy_attachment" "cloudtrail_user_attach" {
  name  = aws_iam_user.user["cloudtrail"].name
  users = [aws_iam_user.user["cloudtrail"].name]
  policy_arn = aws_iam_policy.policy_inline_cloudtrail_graylog-policy.arn
}

##### Create AWS IAM Group #####
resource "aws_iam_group" "iam_group" {
  for_each = toset([
    "awsadmin-group",
    "billing-group",
    "dba-group",
    "prodsupport-group",
    "readonly-group"
  ])
  name = each.key
}

##### Add IAM User to Group #####
resource "aws_iam_user_group_membership" "membership" {
  user   = aws_iam_user.user["grafana"].id
  groups = [aws_iam_group.iam_group["readonly-group"].name]
}

##### Attach Policy to IAM Groups #####
resource "aws_iam_group_policy_attachment" "awsadmin-group" {
  group               = aws_iam_group.iam_group["awsadmin-group"].name
  policy_arn          = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "billing-group" {
  for_each = toset([
    "arn:aws:iam::aws:policy/job-function/Billing",
    "arn:aws:iam::aws:policy/IAMUserChangePassword"
  ])
  group               = aws_iam_group.iam_group["billing-group"].name
  policy_arn          = each.key
}

resource "aws_iam_group_policy_attachment" "dba-group" {
  for_each = toset([
    aws_iam_policy.policy_dba-policy.arn,
    "arn:aws:iam::aws:policy/IAMUserChangePassword"
  ])
  group               = aws_iam_group.iam_group["dba-group"].name
  policy_arn          = each.key
}

resource "aws_iam_group_policy_attachment" "prodsupport-group" {
  for_each = toset([
    aws_iam_policy.policy_prodsupport-policy.arn,
    "arn:aws:iam::aws:policy/IAMUserChangePassword"
  ])
  group               = aws_iam_group.iam_group["prodsupport-group"].name
  policy_arn          = each.key
}

resource "aws_iam_group_policy_attachment" "readonly-group" {
  for_each = toset([
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ])
  group = aws_iam_group.iam_group["readonly-group"].name
  policy_arn = each.value
}

##### Attach IAM Instance Profile #####
resource "aws_iam_instance_profile" "instance_profile" {
  name                    = "ec2codedeploy_instance_profile"
  role                    = aws_iam_role.ec2codedeploy_role.name
}

##### AWS IAM Password Policy #####
resource "aws_iam_account_password_policy" "policy" {
  minimum_password_length                   = "12"
  password_reuse_prevention                 = "24"
}
