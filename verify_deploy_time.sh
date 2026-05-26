#!/bin/bash

set -euo pipefail

KUBECTL_IN_MINIKUBE="/var/lib/minikube/binaries/v1.35.1/kubectl"

# Konfiguracja parametrów
DEPLOYMENT_NAME="nginx-deployment"
TIMEOUT_LIMIT="60s"

echo "=== Rozpoczęcie weryfikacji wdrożenia: ${DEPLOYMENT_NAME} ==="
echo "Oczekiwanie na zakończenie rolloutu (Max: ${TIMEOUT_LIMIT})..."

if docker exec minikube "${KUBECTL_IN_MINIKUBE}" rollout status deployment/${DEPLOYMENT_NAME} --timeout=${TIMEOUT_LIMIT}; then
    echo " [SUKCES] Wdrożenie zakończyło się powodzeniem w wyznaczonym czasie!"
    exit 0
else
    echo " [AWARIA] Przekroczono limit 60 sekund lub wdrożenie zakończyło się błędem."
    echo " Aktualny stan podów:"
    docker exec minikube "${KUBECTL_IN_MINIKUBE}" get pods
    exit 1
fi