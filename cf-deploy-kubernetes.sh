#!/bin/bash

readonly DEFAULT_NAMESPACE=default

deployment_file=${1:=deployment.yml}

[ -z "$KUBERNETES_USER" ] && echo "Please set KUBERNETES_USER" && exit 1;
[ -z "$KUBERNETES_PASSWORD" ] && echo "Please set KUBERNETES_PASSWORD" && exit 1;
[ -z "$KUBERNETES_SERVER" ] && echo "Please set KUBERNETES_SERVER" && exit 1;
[ -z "$DOCKER_IMAGE_TAG" ] && echo "Please set DOCKER_IMAGE_TAG" && exit 1;


[ ! -f "${deployment_file}" ] && echo "Couldn't find $deployment_file file at $(pwd)" && exit 1;
sed -i "s/\$DOCKER_IMAGE_TAG/$DOCKER_IMAGE_TAG/g" $deployment_file

echo "---> Setting up Kubernetes credentials..."
kubectl config set-credentials deployer --username=$KUBERNETES_USER --password=$KUBERNETES_PASSWORD
kubectl config set-cluster foo.kubernetes.com --insecure-skip-tls-verify=true --server=$KUBERNETES_SERVER
kubectl config set-context foo.kubernetes.com/deployer --user=deployer --namespace=$DEFAULT_NAMESPACE --cluster=foo.kubernetes.com
kubectl config use-context foo.kubernetes.com/deployer

echo "---> Submittinig a deployment to Kubernetes..."
kubectl apply -f $deployment_file

