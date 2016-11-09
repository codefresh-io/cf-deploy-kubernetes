#!/bin/bash

readonly DEFAULT_NAMESPACE=default

deployment_file=${1:-deployment.yml}

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

echo "---> Waiting for a succesful deployment status..."

available=1
next_wait_time=0
until [ $available -eq 0 -o $next_wait_time -eq 10 ]; do

	# Unfortunately, we can't use the `kubectl rollout status` command at the moment.
	# The command won't wait until all the replicas are available until the following
	# pull request will be merged:
	# https://github.com/kubernetes/kubernetes/pull/31499
	status=$(kubectl get -f $deployment_file -o jsonpath="{.status.Replicas} {.status.AvailableReplicas} {.status.UpdatedReplicas}")
	updatedReplicas=$(echo $status | awk '{print $3}')
	availableReplicas=$(echo $status | awk '{print $2}')
	replicas=$(echo $status | awk '{print $1}')

	echo "---> Current deployment status: updatedReplicas: $updatedReplicas, availableReplicas: $availableReplicas, totalReplicas: $replicas"
	[ $updatedReplicas -eq $replicas -a $availableReplicas -eq $replicas ] && available=0 || available=1

	sleep $(( next_wait_time++ ))
done

exit $available

