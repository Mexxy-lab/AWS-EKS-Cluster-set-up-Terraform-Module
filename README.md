# AWS EKS Infrastructure with Terraform Modules

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

### Usage

- Update the variables.tf file in root directory with your desired values and run the following commands

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "eks_cluster" {
  source       = "./modules/eks-cluster"
  cluster_name = var.eks_cluster_name
  subnet_ids   = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  k8s_version  = "1.26"
}

module "eks_node_group" {
  source       = "./modules/eks-node-group"
  cluster_name = module.eks_cluster.cluster_name
  subnet_ids   = module.vpc.private_subnet_ids
  policy_arns  = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

### Deployment

- Make sure you have AWS credentials configured (aws configure) and then run:

```bash
terraform init
terraform plan
terraform 
```

### Cleanup

- To delete all resources created by this configuration:

```bash
terraform destroy
```
