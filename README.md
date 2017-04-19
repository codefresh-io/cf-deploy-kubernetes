# Abstract

This is the source code for the `codefresh/cf-deploy-kubernetes` container.
This container is used to demonstrate a Kubernetes deployment using Codefresh.io

# Assumptions

The deployment script makes the following assumptions about your application and
Kubernetes configuration:

1. The application is deployed using the Kubernetes deployment API (versus the
the replication controller directly). For more information read
http://kubernetes.io/docs/user-guide/deployments/
2. The tested codebase has a yaml file (i.e. deployment.yml) that describes the Kubernetes deployment
parameters and configuration of your application.
3. The script processes deployment.yml as a simple template where all `{{ ENV_VARIABLE }}` are replaced with a value of $ENV_VARIABLE deployment.yml
4. At the moment, only the basic username/pass authentication is supported.

# Configuration

The following env variables control the deployment configuration:

1. KUBERNETES_DEPLOYMENT_TIMEOUT - How much to wait for a successful deployment
before failing the build. Defaults to 120 (secs).
2. KUBERNETES_USER - The user for the Kubernetes cluster. Mandatory.
3. KUBERNETES_PASSWORD - The password for the Kubernetes cluster. Mandatory.
4. KUBERNETES_SERVER - The server (HTTPS endpoint) of the Kubernetes cluster's
API. Mandatory.

# Usage in codefresh.io

### deployment.yml

```yaml
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: api-svc
spec:
  replicas: 1
  template:
    metadata:
      annotations:
        revision: "{{CF_REVISION}}"
      labels:
        app: api-svc
    spec:
      containers:
        - name: apisvc
          image: myrepo/apisvc:{{CF_BRANCH}}
          ports:
            - containerPort: 80
              name: http

```

### codefresh.yml
```yaml
---
version: '1.0'

steps:
  build:
    type: build
    working-directory: ${{initial-clone}}
    image-name: $docker-image
    tag: ${{CF_BRANCH}}
  push:
    type: push
    candidate: ${{build}}
    tag: ${{CF_BRANCH}}

  deploy-to-kubernetes:
    image: codefresh/cf-deploy-kubernetes
    tag: latest
    working-directory: ${{initial-clone}}
    commands:
      - /cf-deploy-kubernetes deployment.yml
    environment:
      - KUBERNETES_USER=${{KUBERNETES_USER}}
      - KUBERNETES_PASSWORD=${{KUBERNETES_PASSWORD}}
      - KUBERNETES_SERVER=${{KUBERNETES_SERVER}}
```
