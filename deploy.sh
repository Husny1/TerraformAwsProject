#!/bin/bash
#
# run the script to deploy the fixtures for the infrastructure.
# the script will create the infrastructure as well as set up the containers on the EC2 instances, then release the statelock.
# Pre-requisites:
# - Terraform, AWS CLI, Ansible
# - AWS CLI credentials configured
# - Ensure your SSH key is in the ~/.ssh folder

# Key is .gitignored, change paths to key folder if needed.
# Ensure your key is in: ~/.ssh folder.

# setting paths for SSH keys into vars
PUBLIC_KEY_PATH="$HOME/.ssh/admin.pub"
PRIVATE_KEY_PATH="$HOME/.ssh/admin.pem"

# check if a commands exist 
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "$1 not installed. Install it and try again."
        exit 1
    else
        echo "$1 found."
    fi
}

# Verify dependencies
echo "Checking dependencies..."
check_command terraform
check_command aws
check_command ansible
check_command ssh-keygen

echo "All required tools found. Continuing..."

# check for pub key 
echo "Checking AWS credentials..."
if aws sts get-caller-identity >/dev/null 2>&1; then
    echo "AWS credentials confirmed."
else
    echo "Failed to verify AWS credentials. Exiting."
    exit 1
fi

#  function that will check for ssh
echo "Checking if SSH keys exist..."
if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    echo "SSH private key not found, generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY_PATH" -N "" || { echo "Failed to generaye SSH key. Exiting."; exit 1; }
    echo "SSH key generated."
else
    echo "Private key found."
fi

#  function that will check for pub key 
echo "Checking public key..."
if [ ! -f "$PUBLIC_KEY_PATH" ]; then
    echo "Public key not found, generating from private key..."
    ssh-keygen -y -f "$PRIVATE_KEY_PATH" > "$PUBLIC_KEY_PATH" || { echo "Failed to generaye public key. Exiting."; exit 1; }
    echo "Public key generated."
else
    echo "Public key found."
fi
## echoes provided indicate the errror 
# get into the infra dir
cd infra || { echo "Infrastructure directory not found. Exiting."; exit 1; }

# Terraform Initialize
echo "Initializing Terraform..."
terraform init || { echo "Failed to initialize Terraform. Exiting."; exit 1; }

#Terraform Validate
echo "Validating Terraform..."
terraform validate || { echo "Terraform validation failed. Exiting."; exit 1; }

# Terraform apply
echo "Running Terraform apply..."
terraform apply -auto-approve || { echo "Terraform apply failed. Exiting."; exit 1; }

# Ansible playbooks
echo "Running Ansible playbooks..."
ansible-playbook playbook.yml -i inventory1.yml --private-key "$PRIVATE_KEY_PATH" || { echo "Error running Ansible playbook. Exiting."; exit 1; }

#  destroy Terraform
echo "Destroying infrastructure (optional)..."

# comment/uncomment this line if u dont wanna destroy and keep it running
terraform destroy -auto-approve

echo "Script completed. Check the server."
