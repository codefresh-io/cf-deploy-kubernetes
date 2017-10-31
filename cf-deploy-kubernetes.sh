#!/bin/bash

fatal() {
   echo "ERROR: $1"
   exit 1
}

readonly DEFAULT_NAMESPACE=${KUBERNETES_NAMESPACE:-default}
readonly KUBECTL_ACTION=${KUBECTL_ACTION:-apply}
[[ $KUBECTL_ACTION =~ ^(apply|create|replace)$ ]] || fatal "KUBECTL_ACTION should be one of apply|create|replace "

deployment_file=${1:-deployment.yml}

: ${KUBERNETES_DEPLOYMENT_TIMEOUT:=120}


if [[ -z "${KUBECONFIG}" ]]; then

    [ -z "$KUBERNETES_USER" ] && echo "Please set KUBERNETES_USER" && exit 1;
    [ -z "$KUBERNETES_PASSWORD" ] && echo "Please set KUBERNETES_PASSWORD" && exit 1;
    [ -z "$KUBERNETES_SERVER" ] && echo "Please set KUBERNETES_SERVER" && exit 1;

    echo "---> Setting up Kubernetes credentials..."
    kubectl config set-credentials deployer --username=$KUBERNETES_USER --password=$KUBERNETES_PASSWORD
    kubectl config set-cluster foo.kubernetes.com --insecure-skip-tls-verify=true --server=$KUBERNETES_SERVER
    kubectl config set-context foo.kubernetes.com/deployer --user=deployer --namespace=$DEFAULT_NAMESPACE --cluster=foo.kubernetes.com
    kubectl config use-context foo.kubernetes.com/deployer
fi

if [[ -n KUBECONTEXT ]]; then
  kubectl config use-context "${KUBECONTEXT}"
fi

# [ -z "$DOCKER_IMAGE_TAG" ] && echo "Please set DOCKER_IMAGE_TAG" && exit 1;
[ ! -f "${deployment_file}" ] && echo "Couldn't find $deployment_file file at $(pwd)" && exit 1;


DEPLOYMENT_FILE=${deployment_file}-$(date '+%y-%m-%d_%H-%M-%S').yml
$(dirname $0)/template.sh "$deployment_file" > "$DEPLOYMENT_FILE" || fatal "Failed to apply deployment template on $deployment_file"


echo "---> Kubernetes objects to deploy in  $deployment_file :"
KUBECTL_OBJECTS=/tmp/deployment.objects
kubectl convert -f "$DEPLOYMENT_FILE" --local=true --no-headers=true -o=custom-columns="KIND:{.kind},NAME:{.metadata.name}" > >(tee $KUBECTL_OBJECTS) 2>${KUBECTL_OBJECTS}.errors
if [ $? != 0 ]; then
   cat ${KUBECTL_OBJECTS}.errors
   fatal "Failed to parse $deployment_file "
fi

DEPLOYMENT_NAME=$(awk '/^Deployment /{a=$2}END{print a}' $KUBECTL_OBJECTS)

echo "---> Submitting a deployment to Kubernetes by kubectl $KUBECTL_ACTION "
kubectl $KUBECTL_ACTION -f "$DEPLOYMENT_FILE" || fatal "Deployment submitting Failed"

if [ -n "$DEPLOYMENT_NAME" ]; then
    echo "---> Waiting for a successful deployment/${DEPLOYMENT_NAME} status..."
    timeout -s SIGTERM -t $KUBERNETES_DEPLOYMENT_TIMEOUT kubectl rollout status deployment/"${DEPLOYMENT_NAME}" || fatal "Deployment Failed"
fi

