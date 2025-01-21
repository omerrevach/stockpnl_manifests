## Manifests of the stockpnl app

### This handles the deployment of the stockpnl app that is in another repo. tf modules that deplo a vpc with nat instance as well and deploy and eks cluster.There is a helm chart for each microservice and for the mysql db as well.

#### `Prerequisites`
- terraform
- Docker
- kubectl
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

