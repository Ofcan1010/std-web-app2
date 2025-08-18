#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${REGISTRY:-docker.io/youruser}"
APP_PREFIX="${APP_PREFIX:-std}"
COMMIT_SHA="${COMMIT_SHA:-$(git rev-parse --short HEAD || echo local)}"
BRANCH="${BRANCH:-${GITHUB_REF_NAME:-$(git branch --show-current || echo local)}}"

BACKEND_IMAGE="$REGISTRY/$APP_PREFIX-backend:$COMMIT_SHA"
FRONTEND_IMAGE="$REGISTRY/$APP_PREFIX-frontend:$COMMIT_SHA"

echo "[CI] Build & tag: $BACKEND_IMAGE / $FRONTEND_IMAGE"

docker build -t "$BACKEND_IMAGE" ./backend
docker build -t "$FRONTEND_IMAGE" ./frontend

# İsteğe bağlı: branch’e göre ek tag
if [[ "$BRANCH" == "main" ]]; then
  docker tag "$BACKEND_IMAGE" "$REGISTRY/$APP_PREFIX-backend:prod"
  docker tag "$FRONTEND_IMAGE" "$REGISTRY/$APP_PREFIX-frontend:prod"
else
  docker tag "$BACKEND_IMAGE" "$REGISTRY/$APP_PREFIX-backend:dev"
  docker tag "$FRONTEND_IMAGE" "$REGISTRY/$APP_PREFIX-frontend:dev"
fi

echo "[CI] Push images"
docker push "$BACKEND_IMAGE"
docker push "$FRONTEND_IMAGE"
[[ "$BRANCH" == "main" ]] && { docker push "$REGISTRY/$APP_PREFIX-backend:prod"; docker push "$REGISTRY/$APP_PREFIX-frontend:prod"; } || { docker push "$REGISTRY/$APP_PREFIX-backend:dev"; docker push "$REGISTRY/$APP_PREFIX-frontend:dev"; }

echo "[CI] Done."
