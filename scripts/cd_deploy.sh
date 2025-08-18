#!/usr/bin/env bash
set -euo pipefail

KUBE_CONTEXT="${KUBE_CONTEXT:-default}"
NAMESPACE="${NAMESPACE:-dev}"  # main'de prod kullanacağız
REGISTRY="${REGISTRY:-docker.io/youruser}"
APP_PREFIX="${APP_PREFIX:-std}"
COMMIT_SHA="${COMMIT_SHA:-latest}"

echo "[CD] Deploy to namespace: $NAMESPACE (context: $KUBE_CONTEXT)"

# Manifesteri apply et (env/secret önceden hazır varsayımı)
kubectl --context "$KUBE_CONTEXT" apply -f k8s/namespace.yaml
kubectl --context "$KUBE_CONTEXT" -n "$NAMESPACE" apply -f k8s/configmap.yaml -f k8s/secret.yaml
kubectl --context "$KUBE_CONTEXT" -n "$NAMESPACE" apply -f k8s/backend-service.yaml -f k8s/frontend-service.yaml -f k8s/ingress.yaml

# Yeni imajlara geçir
kubectl --context "$KUBE_CONTEXT" -n "$NAMESPACE" set image deployment/backend-deployment backend="$REGISTRY/$APP_PREFIX-backend:$COMMIT_SHA"
kubectl --context "$KUBE_CONTEXT" -n "$NAMESPACE" set image deployment/frontend-deployment frontend="$REGISTRY/$APP_PREFIX-frontend:$COMMIT_SHA"

# Health bekleme (opsiyonel)
kubectl --context "$KUBE_CONTEXT" -n "$NAMESPACE" rollout status deployment/backend-deployment
kubectl --context "$KUBE_CONTEXT" -n "$NAMESPACE" rollout status deployment/frontend-deployment

echo "[CD] Done."
