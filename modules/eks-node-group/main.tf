# Creates an IAM role for the worker nodes

resource "aws_iam_role" "node_role" {
  name = "eks_worker_node_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}
# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "worker_node_policies" {
  count      = length(var.policy_arns)
  policy_arn = var.policy_arns[count.index]
  role       = aws_iam_role.node_role.name
}
# Create the EKS node group
resource "aws_eks_node_group" "nodes" {
  cluster_name    = var.cluster_name
  node_group_name = "eks_node"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

# This is the node configuration of the cluster. Would deploy 3 nodes per desired size 
  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = ["t3.small", "t3.medium", "t3.large"]
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"

  depends_on = [aws_iam_role_policy_attachment.worker_node_policies]
}
