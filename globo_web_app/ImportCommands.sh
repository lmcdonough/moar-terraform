#Use the values output by the JuniorAdminIssue.ps1 or junior_admin.sh script

terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table.private[2]" "rtb-0d386215a4904fe8b"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table_association.private[2]" "subnet-0f33dc004ab618a82/rtb-0d386215a4904fe8b"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_subnet.private[2]" "subnet-0f33dc004ab618a82"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table_association.public[2]" "subnet-0c039ec86cd397b20/rtb-09fb8e9be1de6a4cb"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_subnet.public[2]" "subnet-0c039ec86cd397b20"