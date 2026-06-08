# Web App on AWS - Terraform Deployment

Deploy a complete web application infrastructure on AWS using Terraform with VPC networking, EC2 web server, RDS MySQL database, and S3 static assets bucket.

## 1. Architecture

### 1.1 Infrastructure Diagram

```
                              Internet
                                 |
                                 v
                         [Internet Gateway]
                                 |
         +-----------------------+-----------------------+
         |                                               |
         v                                               v
              [Public Subnet AZ1]           [Public Subnet AZ2]
              10.0.1.0/24                  10.0.2.0/24
              [EC2 Web Server]              [EC2 Web Server]
              Apache + PHP                  (standby)
                    |                              |
                    v                              v
         [NAT Gateway]                    [NAT Gateway]
                    |                              |
         +-----------------------+-----------------------+
         |                                               |
         v                                               v
         [Private Subnet AZ1]            [Private Subnet AZ2]
         10.0.10.0/24                   10.0.20.0/24
         [RDS MySQL Primary]             [RDS MySQL Standby]
         [S3 Endpoint]                   [S3 Endpoint]
                    |                              |
                    v                              v
              [S3 Bucket]  <---- VPC Endpoint ----+
         (Static Assets)
```

### 1.2 Components


| Component        | Description                                                     | Public Access         |
| ---------------- | --------------------------------------------------------------- | --------------------- |
| VPC              | Custom VPC 10.0.0.0/16 with public/private subnets across 2 AZs | -                     |
| Internet Gateway | Connects VPC to the internet                                    | Yes                   |
| NAT Gateway      | Allows EC2 in private subnets to access the internet            | -                     |
| EC2 Web Server   | Amazon Linux 2023, Apache + PHP 8.x                             | Yes (HTTP/HTTPS)      |
| RDS MySQL        | Multi-AZ MySQL 8.x, stored in Secrets Manager                   | No                    |
| S3 Bucket        | Static assets, encrypted, no public access                      | No (via VPC Endpoint) |
| Security Groups  | Firewall rules for web and database tier                        | -                     |


## 2. Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.3.0
- AWS Account with appropriate IAM permissions
- AWS CLI configured (`aws configure`)
- SSH Key Pair (optional, for EC2 access)

## 3. Quick Start

### Step 1: Create Backend Resources (S3 + DynamoDB)

Terraform state is stored remotely in S3 with DynamoDB locking to prevent concurrent modifications.

**Terraform State on S3:**

Terraform State on S3

The S3 bucket stores the `terraform.tfstate` file with **versioning enabled** — every `terraform apply` creates a new version, allowing you to roll back if needed.

**DynamoDB State Lock:**

DynamoDB State Lock

DynamoDB table `webapp-tf-locks` holds the active lock record (`LockID`, `Status:Locked`, `Owner`), preventing other users or processes from running `terraform apply` while a deployment is in progress.

**Using AWS CLI:**

```bash
# Create S3 bucket
aws s3 mb s3://webapp-tf-state-demo --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket webapp-tf-state-demo \
  --versioning-configuration Status=Enabled

# Create DynamoDB table
aws dynamodb create-table \
  --table-name webapp-tf-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Step 2: Initialize Terraform

Terraform Init

```bash
terraform init
```

Result — all providers and modules downloaded successfully:

```
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v5.90.0...
Terraform has been successfully initialized!
```

### Step 3: Review the Plan

Terraform Plan

```bash
terraform plan
```

Result — 16 resources to be created:

```
Plan: 16 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_instance_id       = (known after apply)
  + rds_endpoint          = (sensitive)
  + s3_bucket_arn         = (known after apply)
  + web_server_public_ip  = (known after apply)
```

### Step 4: Apply the Configuration

Terraform Apply

```bash
terraform apply -auto-approve
```

Result — all resources created in ~3-5 minutes:

```
Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

Outputs:
web_server_public_ip = "32.196.121.197"
rds_endpoint        = <sensitive>
s3_bucket_arn       = "arn:aws:s3:::webapp-static-assets-..."
```

## 4. Project Structure

```
terraform_project/
├── main.tf                    # Root module — orchestrates all child modules
├── providers.tf               # AWS provider + S3 remote backend
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars           # Variable overrides (gitignored)
└── modules/
    ├── vpc/                   # VPC, subnets, IGW, NAT Gateway, route tables
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-groups/       # Web SG, RDS SG, VPC Endpoint for S3
    │   ├── main.tf
    │   └── variables.tf
    ├── ec2/                  # EC2 instance, IAM role, instance profile
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── user_data.sh      # Bootstrap script (Apache + PHP)
    ├── rds/                  # RDS MySQL, subnet group, Secrets Manager
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/                   # S3 bucket, versioning, encryption, policy
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 5. Configuration

### Variables


| Variable               | Description                        | Default                            |
| ---------------------- | ---------------------------------- | ---------------------------------- |
| `aws_region`           | AWS region                         | `us-east-1`                        |
| `project`              | Project name                       | `webapp`                           |
| `environment`          | Environment name                   | `dev`                              |
| `vpc_cidr`             | VPC CIDR block                     | `10.0.0.0/16`                      |
| `public_subnet_cidrs`  | Public subnet CIDRs                | `["10.0.1.0/24", "10.0.2.0/24"]`   |
| `private_subnet_cidrs` | Private subnet CIDRs               | `["10.0.10.0/24", "10.0.20.0/24"]` |
| `instance_type`        | EC2 instance type                  | `t3.micro`                         |
| `ami_id`               | AMI ID for EC2 (must match region) | **Required** — no default          |
| `db_instance_class`    | RDS instance class                 | `db.t3.micro`                      |
| `db_password`          | Database password                  | `ChangeMe123!`                     |


### Override Variables

Create a `terraform.tfvars` file:

```hcl
aws_region    = "us-east-1"
project       = "webapp"
instance_type = "t3.small"
ami_id        = "ami-0e4e7383a06c2df4e"   # Amazon Linux 2023 — us-east-1
db_password   = "YourSecurePassword123!"
```

> To find the correct AMI ID for your region, run:
> `aws ssm get-parameter --name /aws/service/amazonlinux/2023/hvm-arm64/gpu-ami-minimal/20250604.0/image-id --region us-east-1`

## 6. AWS Console Verification

### EC2 Instances

EC2 Console

The web server EC2 instance is running in the public subnet with a public IP address assigned.

### S3 Buckets

S3 Console

The static assets S3 bucket is created with:

- **Encryption** enabled (AES-256)
- **Versioning** enabled
- **Public access blocked**
- **S3 policy** enforcing HTTPS only

### Database Connection

RDS Connection

RDS MySQL is deployed in private subnets across 2 Availability Zones with Multi-AZ enabled. The connection is established from the web server in the public subnet.

### MySQL Database

MySQL Database

The RDS MySQL instance shows:

- **Multi-AZ**: Standby replica in a second Availability Zone for high availability
- **Endpoint**: Internal DNS name used by the EC2 web server to connect
- **Encryption**: Enabled (AWS-managed KMS)

## 7. Accessing the Application

After deployment, access the web server at:

```
http://<web_server_public_ip>/
```

### Pages Available


| URL            | Description                                     |
| -------------- | ----------------------------------------------- |
| `/`            | Main page — server info, PHP version, DB config |
| `/db_test.php` | Database connection test                        |


### Main Page — Web Server on EC2

Web Server on EC2

The main page displays:

- **Server Info**: PHP version and Apache version
- **Database Config**: RDS endpoint, database name, DB username
- **S3 Static Assets**: S3 bucket name

### Database Connection Test

Database Connection

The database connection test verifies connectivity from the EC2 web server to the RDS MySQL instance in the private subnet.

## 8. Troubleshooting

### Problem: `ERR_CONNECTION_REFUSED` — Apache not responding

**Symptoms:** Web browser shows "refused to connect" but EC2 is running.

**Diagnosis:** SSH to the instance and check:

```bash
# Check if Apache is running
sudo systemctl status httpd

# Check if port 80 is listening
sudo ss -tlnp | grep :80
```

**Common causes:**

1. **Wrong package name** — On Amazon Linux 2023, the package is `php-mysqlnd`, not `php-mysql`. If `yum install` fails, httpd is never installed.
2. **Apache not installed** — If `yum install httpd` fails silently (e.g., wrong package), Apache is missing.
3. **User data not re-running** — AWS only executes `user_data` on **first boot**. Editing `user_data.sh` and running `terraform apply` does NOT re-run the script on an existing instance. You must force recreation:

```bash
# Force instance recreation with new user_data
terraform taint module.ec2.aws_instance.web
terraform apply -auto-approve
```

1. **Wrong init system** — Amazon Linux 2 uses `service httpd start`; Amazon Linux 2023 uses `systemctl start httpd`. Using the wrong command silently fails.

**Fixed `user_data.sh` for Amazon Linux 2023:**

```bash
#!/bin/bash
# Apache + PHP installation for Amazon Linux 2023

yum update -y
yum install -y httpd php php-mysqlnd   # php-mysqlnd, NOT php-mysql

systemctl start httpd                   # systemctl for AL2023
systemctl enable httpd

mkdir -p /var/www/html
# ... write PHP files ...
```

### Problem: `terraform apply` says "no changes"

**Cause:** Terraform only updates resources when the configuration changes. If `user_data` is unchanged, the EC2 instance is not re-provisioned.

**Solution:** Use `terraform taint` to force recreation:

```bash
terraform taint module.ec2.aws_instance.web
terraform apply -auto-approve
```

## 9. Security Considerations

- **RDS** is deployed in **private subnets** — not directly accessible from the internet
- **Security groups** follow **principle of least privilege**:
  - Web SG: HTTP (80) + HTTPS (443) + SSH (22) from `0.0.0.0/0`
  - RDS SG: MySQL (3306) only from Web SG
- **S3 bucket** has **public access blocked** by default
- All traffic to S3 goes through a **VPC Endpoint** (no internet traversal)
- Database passwords stored in **AWS Secrets Manager**
- EC2 uses **IAM roles** instead of static access keys

## 10. Maintenance

### SSH to EC2

```bash
ssh -i ~/.ssh/your-key.pem ec2-user@<public_ip>
```

### View Bootstrap Logs

```bash
sudo cat /var/log/cloud-init-output.log
```

### Upload Static Assets to S3

```bash
aws s3 sync ./static/ s3://<bucket-name>/ --region us-east-1
```

### Update Application

After modifying `user_data.sh`, re-provision the instance:

```bash
terraform taint module.ec2.aws_instance.web
terraform apply -auto-approve
```

## 11. Cleanup

Destroy all resources to avoid ongoing charges:

Terraform Destroy

```bash
terraform destroy -auto-approve
```

All 16 resources are destroyed in sequence — RDS first, then EC2, S3, security groups, VPC components, and finally the VPC itself.