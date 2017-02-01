# Abstract

This is the source code for the `codefresh/cf-deploy-kubernetes` container.
This container is used to demonstrate a Kubernetes deployment using Codefresh.io

For a complete example, check:
https://github.com/codefresh-io/cf-deploy-kubernetes-demo

# Assumptions

The deployment script makes the following assumptions about your application and
Kubernetes configuration:

1. The application is deployed using the Kubernetes deployment API (versus the
the replication controller directly). For more information read
http://kubernetes.io/docs/user-guide/deployments/
2. The tested codebase has a yaml file that describes the Kubernetes deployment
parameters and configuration of your application.
3. At the moment, only the basic username/pass authentication is supported.

# Configuration

The following env variables control the deployment configuration:

1. KUBERNETES_DEPLOYMENT_TIMEOUT - How much to wait for a successful deployment
before failing the build. Defaults to 120 (secs).
2. KUBERNETES_USER - The user for the Kubernetes cluster. Mandatory.
3. KUBERNETES_PASSWORD - The password for the Kubernetes cluster. Mandatory.
4. KUBERNETES_SERVER - The server (HTTPS endpoint) of the Kubernetes cluster's
API. Mandatory.
5. DOCKER_IMAGE_TAG - The docker tag to use for the deployment. Requires the
`deployment.yml` file to specify a `$DOCKER_IMAGE_TAG` variable so it can be
substitutes at deployment time.
6. FORCE_RE_CREATE_RESOURCE - Will force re-creation of the deployment


