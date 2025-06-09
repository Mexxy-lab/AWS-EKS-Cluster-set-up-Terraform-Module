# AWS EKS Infrastructure with Terraform Modules deployed via a git push

## Overview

This Terraform project provisions an Amazon EKS cluster and supporting infrastructure using a modular architecture. It includes:

- **VPC Module**: Creates a VPC with public and private subnets.
- **EKS Cluster Module**: Provisions the EKS control plane.
- **EKS Node Group Module**: Creates managed node groups for the EKS cluster.

---

## Project Structure

```text
.
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── vpc/
│   ├── eks-cluster/
│   └── eks-node-group/

Git repo URL - 

### Usage

- Update the variables.tf file in root directory with your desired values and run the following commands

### Deployment

- Make sure you have AWS credentials configured (aws configure) and then run:

```bash
terraform init
terraform plan
terraform apply
```

### Cleanup

- To delete all resources created by this configuration:

```bash
terraform destroy
```

### Why a VPC is required for an EKS cluster-

## Network Isolation

- The VPC provides network-level isolation for Kubernetes resources. It acts as the private network for your cluster.

## Subnet Placement

- Kubernetes nodes (EC2 instances) and control plane components must reside inside private or public subnets.
- Without subnets inside a VPC, there's no way to place your worker nodes or let the control plane connect to them.

## Security Groups & Routing

- The VPC allows you to define security groups, route tables, NACLs, and Internet Gateways — all necessary for managing:

  - Internal/external traffic
  - Communication between pods
  - Access to the internet (e.g., for pulling images)

## EKS Control Plane Requirements

- The EKS control plane needs to be able to communicate with your worker nodes over the network, which requires at least two subnets in different AZs.
