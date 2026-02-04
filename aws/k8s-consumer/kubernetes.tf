# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name]
  }
}

# Test Namespace
resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
    labels = {
      purpose = "vault-testing"
    }
  }

  depends_on = [aws_eks_node_group.main]
}

# Ubuntu Test Deployment
resource "kubernetes_deployment" "ubuntu_test" {
  metadata {
    name      = "ubuntu-test"
    namespace = kubernetes_namespace.test.metadata[0].name
    labels = {
      app = "ubuntu-test"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ubuntu-test"
      }
    }

    template {
      metadata {
        labels = {
          app = "ubuntu-test"
        }
      }

      spec {
        container {
          name  = "ubuntu"
          image = "ubuntu:22.04"

          command = ["/bin/bash", "-c", "apt-get update && apt-get install -y curl dnsutils netcat-openbsd telnet vim && sleep infinity"]

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [aws_eks_node_group.main]
}
