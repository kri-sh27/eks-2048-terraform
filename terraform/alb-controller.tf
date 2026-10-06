# resource "kubernetes_service_account" "aws_load_balancer_controller" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"

#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
#     }
#   }

#   depends_on = [
#     module.eks,
#     aws_iam_role_policy_attachment.alb_controller
#   ]
# }

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.alb_controller
  ]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
    }
  ]

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]
}