resource "helm_release" "argocd" {
  name  = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argo"
  create_namespace = true

  values = [
    file("../argocd/application.yaml")
  ]
}