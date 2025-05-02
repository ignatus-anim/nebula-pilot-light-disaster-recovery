# 🌐 Disaster Recovery Strategy – Project Nebula

## Overview

This document outlines the **Disaster Recovery (DR) strategy** for Project Nebula. Our goal is to maintain **high availability** and ensure **business continuity** in the event of a failure in the **primary AWS region (`eu-west-1`)** by seamlessly failing over to the **disaster recovery region (`us-east-1`)**.


## 🔧 Infrastructure Deployment

All resources are provisioned using **Terraform**. The infrastructure is designed to follow the **Pilot Light strategy**, where minimal services run in the DR region until a failover is required.


## 🌍 Global Traffic Management

* **AWS Global Accelerator** is used to route user traffic to the correct region.
* It points to **two Application Load Balancers (ALBs)**:

  * One in the **Primary Region** (`eu-west-1`)
  * One in the **DR Region** (`us-east-1`)


## 🖥️ Application Layer (EC2)

* **Primary Region**:

  * EC2 instances are managed using **Launch Templates** and **Auto Scaling Groups (ASG)**.
  * ASG `desired_capacity` is set to **1**.
* **DR Region**:

  * ASG is created but `desired_capacity` is set to **0**.
  * Instances are spun up only during failover.


## 🛢️ Database Layer (MySQL RDS)

* **Primary Region** hosts the **main RDS instance**.
* **DR Region** contains a **read replica** of the RDS.
* During failover, the **read replica is promoted** to a standalone primary DB.


## 🗃️ Storage Layer (S3)

* Two S3 buckets:

  * One in **Primary**
  * One in **DR**
* **Cross-region replication (CRR)** is enabled to sync objects from Primary to DR.


## 🛡️ IAM Roles and Permissions

* IAM roles provide:

  * EC2 access to S3
  * Lambda permissions
  * RDS access
  * General service access control
* These roles are created using a dedicated **IAM module**.


## 🔐 Secrets Management

* **AWS Systems Manager (SSM) Parameter Store** is used for:

  * Storing database endpoints
  * S3 bucket names
  * Other sensitive configuration values


## 🌐 Networking (VPC)

* Custom **VPCs** are configured in both regions.
* Subnets, route tables, internet gateways, and security groups are created using the **VPC module**.


## ⚠️ Failover Mechanism (Failover Module)

### ☁️ CloudWatch Alarms

* Monitors:

  * ALB health in the primary region
  * EC2 CPU utilization

### 📝 SSM Document

* Defines a runbook to:

  * Create **AMI** from the latest EC2
  * Trigger failover automation

### 🧠 Lambda Function (Failover Logic)

The Lambda is triggered when CloudWatch detects failure and executes the following:

1. **Promotes RDS Read Replica** to primary in DR.
2. **Updates DR ASG**:

   * Sets `desired_capacity` from `0` to `1`
   * Spins up EC2 in the DR region.
3. **Updates SSM Parameters**:

   * RDS endpoint to DR database
   * S3 bucket references to DR bucket


## ✅ Post-Failover State

After failover:

* Traffic is routed to **DR ALB** by Global Accelerator.
* EC2 and RDS are **fully active** in the DR region.
* Users experience **minimal disruption**.


## 🔁 Recovery Back to Primary (Optional)

To return to the primary region once it's stable:

* Recreate the AMI and EC2 instance
* Resync the database (reverse replication or dump & restore)
* Reset Global Accelerator to point back to primary ALB
* Set DR ASG desired capacity back to `0`


