#!/bin/bash

HOSTED_ZONE_ID="Z022564630P941WV72XMM"  # Hosted Zone ID
DOMAIN_NAME="stockpnl.com"

# get the Load Balancer DNS Name from the NGINX Ingress Controller
LOAD_BALANCER_DNS=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# check if the Load Balancer DNS was retrieved successfully
if [ -z "$LOAD_BALANCER_DNS" ]; then
  echo "Failed to retrieve Load Balancer DNS name. Make sure the NGINX ingress controller is running."
  exit 1
fi

echo "Load Balancer DNS: $LOAD_BALANCER_DNS"

# create the JSON file for Route 53 record update
cat > change-resource-record-sets.json <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$DOMAIN_NAME",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z23TAZ6LKFMNIO",
          "DNSName": "$LOAD_BALANCER_DNS",
          "EvaluateTargetHealth": true
        }
      }
    }
  ]
}
EOF

echo "Generated Route 53 change request: change-resource-record-sets.json"

# Update the Route 53 record
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://change-resource-record-sets.json

# Check the result of the update
if [ $? -eq 0 ]; then
  echo "Route 53 record updated successfully for $DOMAIN_NAME pointing to $LOAD_BALANCER_DNS"
else
  echo "Failed to update Route 53 record."
  exit 1
fi
