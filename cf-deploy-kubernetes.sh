#!/bin/bash

fatal() {
   echo "ERROR: $1"
   exit 1
}

readonly DEFAULT_NAMESPACE=${KUBERNETES_NAMESPACE:-default}

deployment_file=${1:-deployment.yml}

: ${KUBERNETES_DEPLOYMENT_TIMEOUT:=120}

[ -z "$KUBERNETES_USER" ] && echo "Please set KUBERNETES_USER" && exit 1;
[ -z "$KUBERNETES_PASSWORD" ] && echo "Please set KUBERNETES_PASSWORD" && exit 1;
[ -z "$KUBERNETES_SERVER" ] && echo "Please set KUBERNETES_SERVER" && exit 1;
# [ -z "$DOCKER_IMAGE_TAG" ] && echo "Please set DOCKER_IMAGE_TAG" && exit 1;

[ ! -f "${deployment_file}" ] && echo "Couldn't find $deployment_file file at $(pwd)" && exit 1;


DEPLOYMENT_FILE=${deployment_file}-$(date '+%y-%m-%d_%H-%M-%S').yml
$(dirname $0)/template.sh "$deployment_file" > "$DEPLOYMENT_FILE" || fatal "Failed to apply deployment template on $deployment_file"


echo "---> Setting up Kubernetes credentials..."
kubectl config set-credentials deployer --username=$KUBERNETES_USER --password=$KUBERNETES_PASSWORD
kubectl config set-cluster foo.kubernetes.com --insecure-skip-tls-verify=true --server=$KUBERNETES_SERVER
kubectl config set-context foo.kubernetes.com/deployer --user=deployer --namespace=$DEFAULT_NAMESPACE --cluster=foo.kubernetes.com
kubectl config use-context foo.kubernetes.com/deployer

KTYPE=$(cat $DEPLOYMENT_FILE | shyaml get-value kind)

case $KTYPE in
  Deployment)
    echo "---> Submittinig a deployment to Kubernetes..."
    kubectl apply -f "$DEPLOYMENT_FILE" || fatal "Deployment Failed"
    timeout -s SIGTERM -t $KUBERNETES_DEPLOYMENT_TIMEOUT kubectl --namespace=$DEFAULT_NAMESPACE rollout status -f $deployment_file
    echo "---> Waiting for a succesful deployment status..."
  ;;
  Job)
    echo "---> Submittinig a job to Kubernetes..."
    kubectl --namespace=$DEFAULT_NAMESPACE apply -f "$DEPLOYMENT_FILE" || fatal "Job Failed"
  ;;
  Pod)
    echo "---> Submittinig a pod to Kubernetes..."
    kubectl --namespace=$DEFAULT_NAMESPACE create -f "$DEPLOYMENT_FILE" || fatal "Pod Failed"
  ;;
esac

exit $?
