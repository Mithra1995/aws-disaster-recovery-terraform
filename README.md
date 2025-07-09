# AWS Disaster Recovery – Terraform Project

## 📖 Project Overview
This repository contains Terraform code that provisions a **multi-region AWS Disaster Recovery (DR)** environment.  
The goal is to provide high availability, automatic fail-over, and data durability across two AWS regions.

---

## 📁 Project Structure



![image](https://github.com/user-attachments/assets/6b662a82-d652-4ad9-8530-023e6c5d7f4b)



---

## 🚀 How to Use

1. Clone and enter the environment folder  
   ```bash
   git clone https://github.com/<your-username>/aws-disaster-recovery-terraform.git
   cd aws-disaster-recovery-terraform/environments/dev
   
2. Deployment Steps
   
terraform init
terraform plan
terraform apply

Global Traffic Management (Route 53)



🧠 Failover DNS Record Setup

| Record Type | Region     | Role      | Health Check |
|-------------|------------|-----------|---------------|
| A (Alias)   | us-east-1  | PRIMARY   | ✅ Enabled     |
| A (Alias)   | us-west-2  | SECONDARY | ✅ Enabled     |


If the primary ALB fails, Route 53 automatically routes traffic to the secondary region.


## Security Best Practices



. Principle of Least Privilege IAM policies
. RDS is private and non-publicly accessible
. Security Groups allow only HTTP (80) and SSH (22)
. S3 buckets have versioning and replication enabled


✍️ Author



Mithra Balasubramaniam
