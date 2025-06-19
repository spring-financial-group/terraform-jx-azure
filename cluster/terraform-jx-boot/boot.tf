resource "helm_release" "jx-git-operator" {
  name             = "jx-git-operator"
  chart            = "jx-git-operator"
  namespace        = "jx-git-operator"
  repository       = "https://jenkins-x-charts.github.io/repo"
  version          = "0.2.1"
  create_namespace = true

  set = [
    {
      name  = "resources.limits.memory"
      value = "512Mi"
    },
    {
      name  = "resources.requests.memory"
      value = "256Mi"
    },
    {
      name  = "resources.limits.cpu"
      value = "200m"
    },
    {
      name  = "resources.requests.cpu"
      value = "160m"
    },
    {
      name  = "bootServiceAccount.enabled"
      value = true
    },
    {
      name  = "env.NO_RESOURCE_APPLY"
      value = true
    },
    {
      name  = "url"
      value = var.jx_git_url
    },
    {
      name  = "username"
      value = var.jx_bot_username
    }
  ]

  set_sensitive = [
    {
      name  = "password"
      value = var.jx_bot_token
    }
  ]

  dynamic "set_sensitive" {
    for_each = var.job_secret_env_vars
    content {
      name  = "jxBootJobEnvVarSecrets.${set_sensitive.key}"
      value = set_sensitive.value
    }
  }
  dynamic "set" {
    for_each = var.operator_annotations
    content {
      name  = "bootServiceAccount.annotations.${set.key}"
      value = set.value
    }
  }
}
