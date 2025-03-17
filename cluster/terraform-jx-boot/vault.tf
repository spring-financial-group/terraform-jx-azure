resource "helm_release" "vault-operator" {
  count            = var.install_vault ? 1 : 0
  name             = "vault-operator"
  chart            = "vault-operator"
  namespace        = "jx-vault"
  repository       = "oci://ghcr.io/bank-vaults/helm-charts"
  version          = "1.22.3"
  create_namespace = true

  set {
    name = "resources.limits.memory"
    value = "512Mi"
  }
  set {
      name = "resources.requests.memory"
      value = "256Mi"
    }
}

resource "helm_release" "vault-instance" {
  count      = var.install_vault ? 1 : 0
  name       = "vault-instance"
  chart      = "vault-instance"
  namespace  = "jx-vault"
  repository = "https://jenkins-x-charts.github.io/repo"
  version    = "1.0.28"
  depends_on = [helm_release.vault-operator]

  set {
    name = "bankVaultsImage"
    value = "ghcr.io/bank-vaults/bank-vaults:v1.31.2"
  }

  set {
    name = "pvc.size"
    value = "4Gi"
  }
}
