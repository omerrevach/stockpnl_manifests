#!/bin/bash

DB_USER="trading_user"
DB_PASSWORD="trading_pass"
DB_DATABASE="trading_db"
ROOT_PASSWORD="securepassword"

# install kubeseal
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.2/kubeseal-0.19.2-linux-amd64.tar.gz
tar -xvzf kubeseal-0.19.2-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal

# deploy the sealed secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.2/controller.yaml

cat <<EOF > secrets.yml 
apiVersion: v1
kind: Secret
metadata:
  name: my-db-secret
type: Opaque
data:
  mysql-user: $(echo -n "$DB_USER" | base64)
  mysql-password: $(echo -n "$DB_PASSWORD" | base64)
  mysql-database: $(echo -n "$DB_DATABASE" | base64)
  mysql-root-password: $(echo -n "$ROOT_PASSWORD" | base64)
EOF

# seal secret
kubectl create -f secrets.yml --dry-run=client -o yaml | kubeseal --format=yaml > my-sealed-secret.yaml

# apply sealed secret
kubectl apply -f my-sealed-secret.yaml

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