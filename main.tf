provider "aws" {
  region = var.region
}
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
  k8s_version  = var.Version
}
module "eks_node_group" {
  source       = "./modules/eks-node-group"
  cluster_name = module.eks_cluster.cluster_name
  subnet_ids   = module.vpc.private_subnet_ids
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}
