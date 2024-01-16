.DEFAULT_GOAL := help

ARGOCD_VERSION := v2.8.2
ARGO_ROLLOUTS_VERSION := v1.6.4
ARGOCD_DASHBOARD_PORT := 8888

# Targets
.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  setup			Install Argo CD and Argo Rollouts"
	@echo "  dashboard		Open Argo CD and Argo Rollouts dashboards"

.PHONY: setup
setup:
	kubectl create namespace argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml
	kubectl create namespace argo-rollouts || true
	kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/${ARGO_ROLLOUTS_VERSION}/manifests/install.yaml

.PHONY: dashboard
dashboard:
	brew install argoproj/tap/kubectl-argo-rollouts
	kubectl argo rollouts dashboard -n argo-rollouts > /dev/null &
	echo
	kubectl -n argocd port-forward deploy/argocd-server ${ARGOCD_DASHBOARD_PORT}:8080 > /dev/null &
	echo
 