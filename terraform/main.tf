terraform {
  required_version = "~> 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.43"
    }
  }
}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}


provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key

  default_tags {
    tags = {
      CreatedBy = "terraform"
    }
  }
}

data "aws_vpc" "resource" {
  id = "vpc-01f5dce028f371283"
}

data "aws_subnets" "resource" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.resource]
  }

  filter {
    name   = "cidr-block"
    values = [
      "10.0.101.0/24",
      "10.0.102.0/24",
      "10.0.103.0/24"
    ]
  }
}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "demo-app-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  vpc_id     = data.aws_vpc.resource.id
  subnet_ids = data.aws_subnets.resource.ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.large"]
  }

  eks_managed_node_groups = {
    demo = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    demo = {
      kubernetes_groups = [
        "cluster-admin",
      ]
      principal_arn     = "arn:aws:iam::050012553741:user/thatcher"

      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = [
              "default",
              "kube-node-lease",
              "kube-public",
              "kube-system",
              "harness-delegate-ng",
            ]
          }
        }
      }
    }
  }
}