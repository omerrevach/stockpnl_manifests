#!/bin/bash

set -e

# Variables
POLICY_FILE="ebs-csi-policy.json"
POLICY_NAME="EBSCSIControllerPolicy"
ROLE_NAME="EBSCSIControllerRole"
CLUSTER_NAME="stockpnl"
REGION="eu-north-1"

# Get OIDC Provider URL
echo "Fetching OIDC Provider URL for EKS cluster: $CLUSTER_NAME..."
OIDC_URL=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
if [ -z "$OIDC_URL" ]; then
    echo "Error: OIDC Provider URL not found. Ensure the EKS cluster exists and has OIDC enabled."
    exit 1
fi
echo "OIDC URL: $OIDC_URL"

# Step 1: Create the IAM Policy
echo "Creating IAM policy: $POLICY_NAME..."
POLICY_ARN=$(aws iam create-policy --policy-name "$POLICY_NAME" --policy-document file://$POLICY_FILE --query "Policy.Arn" --output text || echo "Policy already exists")
if [[ "$POLICY_ARN" == "Policy already exists" ]]; then
    POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)
fi
echo "Policy ARN: $POLICY_ARN"

# Step 2: Create the IAM Role
echo "Creating IAM role: $ROLE_NAME..."
cat > assume-role-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):oidc-provider/$OIDC_URL"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "$OIDC_URL:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                }
            }
        }
    ]
}
EOF

aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document file://assume-role-policy.json || echo "Role already exists"

# Step 3: Attach the Policy to the Role
echo "Attaching policy to the role..."
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN" || echo "Policy already attached"

# Step 4: Annotate Kubernetes Service Account
echo "Annotating the Kubernetes service account..."
kubectl create serviceaccount ebs-csi-controller-sa --namespace kube-system || echo "Service account already exists"

kubectl annotate serviceaccount ebs-csi-controller-sa \
    eks.amazonaws.com/role-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$ROLE_NAME \
    --namespace kube-system --overwrite

# Step 5: Restart EBS CSI Pods
echo "Restarting EBS CSI driver pods..."
kubectl delete pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver

echo "IAM Role $ROLE_NAME successfully attached to the Kubernetes service account."
