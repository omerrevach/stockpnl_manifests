# This docker file is used to run on the pipelin for the agent

FROM docker:24.0.4-cli
RUN apk add --no-cache python3 py3-pip bash curl openssl git aws-cli zip

RUN apk add dnsutils

RUN apk add py3-virtualenv
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

RUN python3 -m venv /venv

RUN /venv/bin/pip install pylint bandit checkov

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Install Argocd
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
RUN chmod +x /usr/local/bin/argocd