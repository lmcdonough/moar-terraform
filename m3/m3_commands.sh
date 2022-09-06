# Configure an AWS profile with proper credentials
aws configure --profile levi

# Linux or MacOS
export AWS_PROFILE=levi

# Deploy the current environment
terraform init
terraform validate
terraform plan -out m3.tfplan
terraform apply "m3.tfplan"

# Linux and MacOS: Run the junior_admin.sh script
./junior_admin.sh

# Update your terraform.tfvars file to comment out the current
# private_subnets, public_subnets, and subnet_count values and
# uncomment the updated values

# Run the import commands in ImportCommands.txt

terraform plan -out m3.tfplan

# There should be 3 changes where tags are added

terraform apply "m3.tfplan"

terraform destroy