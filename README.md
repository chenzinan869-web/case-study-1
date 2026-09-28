This repository contains the infrastructure (Terraform), the web application (Docker) and the CI/CD pipelines for the core assignment CS1-MA-NCA. The environment runs in the AWS region eu-central-1.

Assignment goal

Design and build an environment with:

at least two web servers;
a database that is only reachable from the web servers;
scaling during peak usage (for example a ticket sale) and low costs outside the peak;
monitoring of the environment;
a deployment strategy for the web content.
Architecture
Internet
   |
[ Application Load Balancer (nca-alb) ]   <- public subnet (+ NAT gateway)
   |
[ ECS Fargate tasks (nca-cluster) ]       <- app subnet, minimum of 2 web servers
   |
[ RDS PostgreSQL (nca-db) ]               <- db subnet, not publicly accessible
Component	Choice
Network	Dedicated VPC with public, app and db subnets, NAT gateway and separate route tables
Compute	Containers on AWS Fargate (deliberately not EC2)
Load balancing	Application Load Balancer (nca-alb)
Container registry	Amazon ECR (nca-web)
Database	Amazon RDS PostgreSQL 5432, Single-AZ, db.t4g.micro, gp2 storage
Scaling	ECS Service Auto Scaling
Monitoring	CloudWatch (alarms + dashboard) and SNS for email notifications
IaC	Terraform
CI/CD	GitHub Actions with a self-hosted runner
Network security

Traffic is separated using security groups:

alb-sg: accepts traffic from the internet to the load balancer;
app-sg: only accepts traffic from the load balancer;
db-sg: only accepts traffic (port 5432) from the web servers.

The database has no public IP address and cannot be reached from the internet.

Scaling
Target tracking on CPU utilization and on the number of requests per target (ALB).
Scheduled scaling for the ticket sale scenario: before the peak, the minimum goes from 2 to 4 tasks, and after the peak it returns to 2. The maximum stays at 8 tasks.

This keeps the number of running tasks as low as possible outside the peak, which keeps costs down.

Monitoring

CloudWatch alarms send a notification via SNS to email:

Alarm	Metric	Threshold
nca-ecs-memory-high	ECS MemoryUtilized	> 80%
nca-rds-cpu-high	RDS CPUUtilization	> 80%
nca-rds-storage-low	RDS FreeStorageSpace	< 2 GiB
nca-rds-connections-high	RDS DatabaseConnections	> 80
nca-alb-5xx-high	ALB HTTPCode_Target_5XX_Count	> 10 in 5 min
nca-alb-latency-high	ALB TargetResponseTime	> 2 s

There is also a CloudWatch dashboard showing the most important metrics.

Repository contents
.
├── *.tf                          # Terraform: VPC, security groups, ALB, ECS, ECR, RDS, autoscaling, monitoring
├── Dockerfile                    # Web application image
├── index.html                    # Static web app
└── .github/workflows/
    ├── infra-deploy.yml          # Infrastructure pipeline (Terraform)
    └── app-deploy.yml            # Application pipeline (build, push to ECR, deploy to ECS)
Getting started
Prerequisites
AWS account with access to eu-central-1
Terraform
AWS CLI, logged in via SSO
Docker
Deploy the infrastructure
bash
terraform init
terraform plan
terraform apply

Note on RDS: on the Fontys AWS account, creating an RDS instance is blocked by a Service Control Policy. Only the Sandbox configuration with storage_type = "gp2" is allowed (gp3 is rejected). The database nca-db was therefore created manually in the Console and then brought under Terraform management with terraform import. After that, terraform plan shows no changes.

Deploy the application

The application is built and deployed automatically by the pipeline. It can also be done manually:

bash
docker build -t nca-web .
# tag and push to ECR (nca-web), then force a new deployment of the ECS service
CI/CD

Two GitHub Actions workflows run on a self-hosted runner:

Workflow	Purpose
infra-deploy.yml	Validates and applies Terraform changes
app-deploy.yml	Builds the Docker image, pushes it to ECR and refreshes the ECS service

This makes both the application and the infrastructure reproducible and traceable through Git.

Requirements (REQ-NCA-P1)
Requirement	Topic	Solution
01	Network segmentation	Public, app and db subnets with security groups
02	Database not public	RDS in db subnet, only reachable via db-sg
03	Containerized web service	Docker on ECS Fargate
04	Dynamic scaling	Target tracking + scheduled scaling
05	Observability	CloudWatch alarms, dashboard and SNS
06	Infrastructure as Code	Terraform
07	CI/CD with self-hosted runner	GitHub Actions
08	DevOps platform	GitHub (source code and deployments)
Documentation

The detailed justification is in separate documents: Design Document, Technology Choices Justification, Monitoring Design, TCO Comparison Report (3 and 5 years) and Deployment Strategy.

Author

Zinan Chen (Somenasi) - Fontys Hogeschool ICT, Cybersecurity
