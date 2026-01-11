# Automated Cloud Security Auditor 🛡️

## Project Overview
This project is an event-driven security tool that automatically scans infrastructure configuration files for vulnerabilities. It uses **Infrastructure as Code (Terraform)** to deploy a serverless pipeline on AWS.

**Goal:** Eliminate manual security reviews by automating policy checks (e.g., detecting public S3 buckets) in real-time.

## 🏗️ Architecture
**Flow:** `User Upload` -> `S3 Event` -> `Lambda (Python)` -> `SNS Alert` -> `Admin Email`

1.  **Trigger:** A user uploads a configuration file (JSON) to an S3 bucket.
2.  **Process:** AWS Lambda is triggered instantly. It parses the file and checks for risk flags (e.g., `"public_access": true`).
3.  **Alert:** If a vulnerability is found, Lambda publishes a message to Amazon SNS.
4.  **Notify:** The security admin receives an immediate email alert.

## 🛠️ Technology Stack
* **Cloud Provider:** AWS (S3, Lambda, SNS, IAM)
* **Infrastructure as Code:** Terraform
* **Language:** Python 3.9 (Boto3 SDK)
* **Security:** IAM Roles with Least Privilege

## 📸 Proof of Concept

### 1. Infrastructure Deployment (Terraform)
*Infrastructure deployed using Terraform to ensure consistency and speed.*
![Terraform Apply](URL_TO_YOUR_TERRAFORM_IMAGE_HERE)

### 2. Vulnerability Simulation
*Uploaded a 'bad_conf.json' file to trigger the security rule.*
![Bad Upload](URL_TO_YOUR_UPLOAD_IMAGE_HERE)

### 3. Real-Time Detection
*The system successfully detected the risk and sent an alert in <2 seconds.*
![Email Alert](URL_TO_YOUR_EMAIL_IMAGE_HERE)

## 🚀 How to Run
1.  Clone the repo:
    ```bash
    git clone [https://github.com/YOUR_USERNAME/aws-serverless-security-auditor.git](https://github.com/YOUR_USERNAME/aws-serverless-security-auditor.git)
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Deploy:
    ```bash
    terraform apply
    ```
