#!/bin/bash

# Database credentials
DB_USER="trading_user"
DB_PASSWORD="trading_pass"
DB_DATABASE="trading_db"
ROOT_PASSWORD="securepassword"

# Install kubeseal
wget -q https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.2/kubeseal-0.19.2-linux-amd64.tar.gz
tar -xvzf kubeseal-0.19.2-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal

# Deploy the Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.2/controller.yaml

# Wait for the Sealed Secrets controller to be ready
echo "Waiting for Sealed Secrets controller to be ready..."
kubectl wait --for=condition=available --timeout=20s -n kube-system deployment/sealed-secrets-controller

# Create an unsealed secret
cat <<EOF > secrets.yml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secrets
  namespace: default
type: Opaque
data:
  mysql-user: $(echo -n "$DB_USER" | base64)
  mysql-password: $(echo -n "$DB_PASSWORD" | base64)
  mysql-database: $(echo -n "$DB_DATABASE" | base64)
  mysql-root-password: $(echo -n "$ROOT_PASSWORD" | base64)
EOF

# Seal the secret using kubeseal
kubectl create -f secrets.yml --dry-run=client -o yaml | kubeseal --controller-name=sealed-secrets-controller --format=yaml > my-sealed-secret.yaml

# Apply the sealed secret
kubectl apply -f my-sealed-secret.yaml
echo "Sealed secret applied successfully."

# Clean up local unsealed secret
rm -f secrets.yml
# add this to secrets
# certificate-arn: $(echo -n "$CERT_ARN" | base64)

# ingress.yaml
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: app-ingress
#   annotations:
#     kubernetes.io/ingress.class: alb
#     alb.ingress.kubernetes.io/scheme: internet-facing
#     alb.ingress.kubernetes.io/target-type: ip
#     alb.ingress.kubernetes.io/subnets: subnet-x, subnet-x
#     alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
#     alb.ingress.kubernetes.io/certificate-arn: ${CERT_ARN}
# spec:
#   rules:
#     - http:
#         paths:
#           - path: /
#             pathType: Prefix
#             backend:
#               service:
#                 name: service-name-here
#                 port:
#                   number: 80