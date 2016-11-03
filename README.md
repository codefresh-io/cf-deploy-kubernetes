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

