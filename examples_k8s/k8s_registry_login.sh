#!/bin/sh

# https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line

CONTAINER_REGISTRY='index.docker.io/v1/'  # for DockerHub use: https://index.docker.io/v1/
CONTAINER_USER_NAME='<your-name>'
CONTAINER_USER_PASSWORD='<your-pword>'
CONTAINER_USER_EMAIL='<your-email>'

K8S_REGCRED_NAME='regcred'

# create regcred for specific namespace
#K8S_NAMESPACE='default'
#kubectl --namespace="${K8S_NAMESPACE}" create secret docker-registry ${K8S_REGCRED_NAME} --docker-server="${CONTAINER_REGISTRY}" --docker-username="${CONTAINER_USER_NAME}" --docker-password="${CONTAINER_USER_PASSWORD}" --docker-email="${CONTAINER_USER_EMAIL}" --save-config --dry-run=client -o yaml | kubectl --namespace="${K8S_NAMESPACE}" apply -f -

# or:

# create regcred for all namespaces
for K8S_NAMESPACE in $(kubectl get namespaces -o=jsonpath='{.items[*].metadata.name}'); do
    echo ">> Namespace=${K8S_NAMESPACE}"
    kubectl --namespace="${K8S_NAMESPACE}" create secret docker-registry ${K8S_REGCRED_NAME} \
        --docker-server="${CONTAINER_REGISTRY}" \
        --docker-username="${CONTAINER_USER_NAME}" \
        --docker-password="${CONTAINER_USER_PASSWORD}" \
        --docker-email="${CONTAINER_USER_EMAIL}" \
        --save-config \
        --dry-run=client \
        -o yaml | \
    kubectl --namespace="${K8S_NAMESPACE}" apply -f -
done
