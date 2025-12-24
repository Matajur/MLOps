resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = kubernetes_namespace.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.12"

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]

  timeout = 900 # 15 minutes
  wait    = true

  depends_on = [
    kubernetes_namespace.argocd
  ]
}
