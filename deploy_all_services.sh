#!/bin/bash

NAMESPACE="default"

SERVICES=(
  "mysql/helm"
  "auth-service/helm"
  "trade_service/helm"
  "frontend/helm"
)

echo "Starting deployment of services..."

# loop through the services and deploy each
for SERVICE_PATH in "${SERVICES[@]}"; do

  SERVICE_NAME=$(basename $(dirname "$SERVICE_PATH") | tr '_' '-')
  
  echo "Deploying $SERVICE_NAME..."
  
  if [ -d "$SERVICE_PATH" ]; then
    helm upgrade --install "$SERVICE_NAME" "$SERVICE_PATH" --namespace "$NAMESPACE"
    if [ $? -eq 0 ]; then
      echo "$SERVICE_NAME deployment succeeded!"
    else
      echo "$SERVICE_NAME deployment failed!"
      exit 1
    fi
  else
    echo "Error: $SERVICE_PATH does not exist or is not a valid Helm chart!"
    exit 1
  fi
done

# verification
echo "Verifying deployments..."
kubectl get pods -n $NAMESPACE

echo "All services have been deployed successfully!"
