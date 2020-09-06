# resource "aws_iam_policy" "s3-policy" {
#   name        = "s3_policy"
#   path        = "/"
#   description = "My s3 policy"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "s3:*"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#           "${module.group3-s3-utility-bucket-test.bucket_arn}",
#           "${module.group3-s3-utility-bucket-test.bucket_arn}/*"
#       ]
#     }
#   ]
# }
# EOF
# }
# resource "aws_iam_role" "ec2_iam_role" {
#   name               = "EC2-IAM-Role"
#   assume_role_policy = <<EOF
# {
#   "Version" : "2012-10-17",
#   "Statement" :
#   [
#     {
#       "Effect" : "Allow",
#       "Principal" : {
#         "Service" : ["ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
#       },
#       "Action" : "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "ec2_iam_role_policy" {
#   name    = "EC2-IAM-Policy"
#   role    = "aws_iam_role.ec2_iam_role.id"
#   policy  = <<EOF
# {
#   "Version" : "2012-10-17",
#   "Statement" : [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:*",
#         "elasticloadbalancing:*",
#         "cloudwatch:*",
#         "logs:*"
#         "ssm:*"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF


# resource "aws_iam_role_policy_attachment" "ec2-attach-s3" {
#   role       = aws_iam_role.ec2_iam_role.name
#   policy_arn = aws_iam_policy.s3-policy.arn
# }
# resource "aws_iam_role_policy_attachment" "ec2-attach" {
#   role       = aws_iam_role.ec2_iam_role.name
#   policy_arn = aws_iam_policy.ec2_iam_role_policy.arn
# }