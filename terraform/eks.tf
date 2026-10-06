module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.33"

  endpoint_public_access = true

  enable_irsa = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  fargate_profiles = {
    alb_sample_app = {
      name = "alb-sample-app"

      selectors = [
        {
          namespace = "game-2048"
        }
      ]

      subnet_ids = module.vpc.private_subnets
    }

    kube_system = {
      name = "kube-system"

      selectors = [
        {
          namespace = "kube-system"
        }
      ]

      subnet_ids = module.vpc.private_subnets
    }
  }

  addons = {
    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }
  }

  tags = {
    Project = "eks-2048"
  }
}