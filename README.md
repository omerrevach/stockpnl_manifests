## StockPnL Manifests
### This repository contains Kubernetes manifests, Helm charts, and CI/CD pipelines for deploying the StockPnL trading platform. It includes infrastructure provisioning with Terraform, cost-optimized networking with a NAT instance, and advanced Kubernetes features for scalability and reliability


## Features

1. **Helm Charts:**
    - Deploy all microservices and a MySQL database with persistent storage

2. **CD Piplines**
    - CD pipeline for each microservice recieves a trigger when the CI pipeline was completed and  dynamically updates Helm chart tags, creates ArgoCD applications, and sync deployments to the cluster

3. **Secure Credentials:**
    - Sensitive data, such as database credentials, is encrypted using Sealed Secrets.

4. **Kubernetes Enhancements:**
    - **Horizontal Pod Autoscaling** (HPA): Automatically adjusts pod replicas based on resource usage
    - **Pod Disruption** (MaxSkew): Ensures balanced pod distribution during updates and node maintenance

#### `Prerequisites`
- terraform
- kubectl
- kubeseal
- helm

### Steps to setup:

1. **Set up Enviorment with terraform**:
    - go to the tf folder
    - first we will set up the vpc. Go into the vpc_setup_root folder
      ```
      terraform init
      terraform plan
      terraform apply -auto-approve

      # make sure to enter in the input "stockpnl"
      ```
    - move into the eks_setup_root folder and do the same as in the vpc. make sure to enter in the input "stockpnl"

2. **Set up csi**:
    - go to the csi_deployment folder.
        ```
        ./create-ebs-csi.sh
        ```
    - follow the instructions in the deploy_csi_controller.txt file

3. **Deploy sealed secrets**:
    - in the root directory
      ```
      ./deploy_sealed_secrets.sh
      ```
4. **Apply the nginx-ingress-controller**:
    ```
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml
    ```

5. **To deploy all the helm charts together**:
      ```
      ./deploy_all_services.sh
      ```

### Websites that hepled me create this project for anyone interested in doing the same or learning something new:
- Update docker image tag: https://github.com/marketplace/actions/gitops-update-image-tag
- Trigger CD pipeline from CI pipeline: https://medium.com/hostspaceng/triggering-workflows-in-another-repository-with-github-actions-4f581f8e0ceb
- MaxSqew: https://medium.com/@farshadnick/understanding-pod-topology-spread-constraints-in-kubernetes-44d33c85a40f
- bump version: https://dev.to/natilou/automating-tag-creation-release-and-docker-image-publishing-with-github-actions-49jg