#!/bin/bash

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=%s\n", "'$prefix'",vn, $2, $3);
      }
   }'
}


objects() {
parse_yaml $1 | awk -F"=" '/metadata_name=/ && i==1 {print  (NF>1)? $NF : " "; i=0} /kind=/{printf (NF>1)? $NF : "";printf " "; i=1}'
}


fatal() {
   echo "ERROR: $1"
   exit 1
}

readonly KUBECTL_ACTION=${KUBECTL_ACTION:-apply}
[[ $KUBECTL_ACTION =~ ^(apply|create|replace)$ ]] || fatal "KUBECTL_ACTION should be one of apply|create|replace "

deployment_file=${1:-deployment.yml}
: ${KUBERNETES_NAMESPACE:=default}
: ${KUBERNETES_DEPLOYMENT_TIMEOUT:=120}


if [[ -n "$KUBERNETES_SERVER" && -n "$KUBERNETES_USER" && -n "$KUBERNETES_PASSWORD" ]]; then
    unset KUBECONFIG

    echo "---> Setting up Kubernetes credentials..."
    kubectl config set-credentials deployer --username=$KUBERNETES_USER --password=$KUBERNETES_PASSWORD
    kubectl config set-cluster foo.kubernetes.com --insecure-skip-tls-verify=true --server=$KUBERNETES_SERVER
    kubectl config set-context foo.kubernetes.com/deployer --user=deployer --namespace=$KUBERNETES_NAMESPACE --cluster=foo.kubernetes.com
    kubectl config use-context foo.kubernetes.com/deployer

    KUBECONTEXT=foo.kubernetes.com/deployer
else
    if [[ -z "${KUBECONTEXT}" ]]; then
        KUBECONTEXT=$(kubectl config current-context)
        # If KUBECONFIG is set we obligate to set KUBECONTEXT to valid context name
        if [[ -n "${KUBECONFIG}" ]]; then
          echo -e "--- ERROR - KUBECONTEXT Environment variable is not set, please set it to one of integrated contexts: "
          kubectl config get-contexts
          fatal "KUBECONTEXT is not set "
        else
           KUBECONTEXT=$(kubectl config current-context)
        fi
    fi
fi

# Add SERVER_VERSION override and testing capabilities

if [[ -n "${SERVER_VERSION}" ]]; then
    # Statically define SERVER_VERSION from variable override
    echo "Statically defined version: ${SERVER_VERSION}"
    # Assign kubectl version 
    echo "Setting kubectl to version 1.${SERVER_VERSION}"
    cp -f "/usr/local/bin/kubectl1.${SERVER_VERSION}" /usr/local/bin/kubectl 2>/dev/null
else
    #check the cluster version and decide which version of kubectl to use:
    SERVER_VERSION=$(kubectl version --short=true --context "${KUBECONTEXT}" | grep -i server | cut -d ':' -f2 | cut -d '.' -f2 | sed 's/[^0-9]*//g')
    echo "Server minor version: $SERVER_VERSION"
    if (( "$SERVER_VERSION" <= "6" )); then cp -f /usr/local/bin/kubectl1.6 /usr/local/bin/kubectl; fi 2>/dev/null
    if (( "$SERVER_VERSION" == "14" )); then cp -f /usr/local/bin/kubectl1.14 /usr/local/bin/kubectl; fi 2>/dev/null
    if (( "$SERVER_VERSION" >= "15" )); then cp -f /usr/local/bin/kubectl1.15 /usr/local/bin/kubectl; fi 2>/dev/null
    [ ! -f "${deployment_file}" ] && echo "Couldn't find $deployment_file file at $(pwd)" && exit 1;
fi

# Simple testing logic for making sure override versions are set
if [[ -n "${KUBE_CTL_TEST_VERSION}" ]]; then
    KUBE_CTL_VERSION=`kubectl version --client --short`
    echo "Testing kubectl version is set..."
    if [[ "${KUBE_CTL_VERSION}" == *"${KUBE_CTL_TEST_VERSION}"* ]]; then
        echo "Version correctly set"
        echo "Kubectl Version: ${KUBE_CTL_VERSION}"
        echo "Test Version: ${KUBE_CTL_TEST_VERSION}"
        exit 0
    else
        echo "Kubectl Version: ${KUBE_CTL_VERSION}"
        echo "Test Version: ${KUBE_CTL_TEST_VERSION}"
        fatal "Version Mismatch!!!"
        exit 1
    fi
fi    

DEPLOYMENT_FILE=${deployment_file}-$(date '+%y-%m-%d_%H-%M-%S').yml
$(dirname $0)/template.sh "$deployment_file" > "$DEPLOYMENT_FILE" || fatal "Failed to apply deployment template on $deployment_file"


echo "---> Kubernetes objects to deploy in  $deployment_file :"
KUBECTL_OBJECTS=/tmp/deployment.objects
kubectl convert -f "$DEPLOYMENT_FILE" --local=true --no-headers=true -o=custom-columns="KIND:{.kind},NAME:{.metadata.name}" > >(tee $KUBECTL_OBJECTS) 2>${KUBECTL_OBJECTS}.errors
if [ $? != 0 ]; then
   cat ${KUBECTL_OBJECTS}.errors
   echo "Failed to parse $deployment_file with kubectl... "
   echo "Using alternative parsing method... "
   truncate -s 0 $KUBECTL_OBJECTS
   objects $DEPLOYMENT_FILE | tee $KUBECTL_OBJECTS
fi

DEPLOYMENT_NAME=$(awk '/^Deployment /{a=$2}END{print a}' $KUBECTL_OBJECTS)

echo "---> Submitting a deployment to Kubernetes by
   kubectl --context "${KUBECONTEXT}" --namespace "${KUBERNETES_NAMESPACE}" $KUBECTL_ACTION "
kubectl --context "${KUBECONTEXT}" --namespace "${KUBERNETES_NAMESPACE}" $KUBECTL_ACTION -f "$DEPLOYMENT_FILE" || fatal "Deployment submitting Failed"

if [ -n "$DEPLOYMENT_NAME" ]; then
    echo "---> Waiting for a successful deployment/${DEPLOYMENT_NAME} status to namespace ${KUBERNETES_NAMESPACE} ..."
    timeout -s SIGTERM $KUBERNETES_DEPLOYMENT_TIMEOUT kubectl --context "${KUBECONTEXT}" --namespace "${KUBERNETES_NAMESPACE}" rollout status deployment/"${DEPLOYMENT_NAME}" || fatal "Deployment Failed"
fi

