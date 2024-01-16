#!/bin/bash

ARGOCD_VERSION="v2.8.2"
ARGO_ROLLOUTS_VERSION="v1.6.4"
ARGOCD_DASHBOARD_PORT=8888

# Functions
help() {
  echo "Usage: $0 <target>"
  echo ""
  echo "Targets:"
  echo "  checkout:		Checkout branch and push it with '\$1' name"
  echo "  setup			Install Argo CD and Argo Rollouts"
  echo "  dashboard		Open Argo CD and Argo Rollouts dashboards"
}

checkout() {
  git clone https://github.com/Glovo/gitops-basics-workshop.git
  cd gitops-basics-workshop || exit 1
  git checkout -b "$1-gitops-workshop"
  git add .
  git commit -m "Rename placeholder with name"
  git push -u origin "$1-gitops-workshop"
}

setup() {
  kubectl create namespace argocd || true
  kubectl apply -n argocd -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"
  kubectl create namespace argo-rollouts || true
  kubectl apply -n argo-rollouts -f "https://raw.githubusercontent.com/argoproj/argo-rollouts/${ARGO_ROLLOUTS_VERSION}/manifests/install.yaml"
}

dashboard() {
  brew install argoproj/tap/kubectl-argo-rollouts
  kubectl argo rollouts dashboard -n argo-rollouts > /dev/null &
  echo
  kubectl -n argocd port-forward deploy/argocd-server ${ARGOCD_DASHBOARD_PORT}:8080 > /dev/null &
  echo
}

# Main logic
case "$1" in
  "checkout")
    checkout "$2"
    ;;
  "setup")
    setup
    ;;
  "dashboard")
    dashboard
    ;;
  *)
    help
    ;;
esac
