#!/bin/bash
set -euo pipefail
set -x

#NIB_IMAGE="nkp-rocky-9.4-1.29.5-20240618222417"
NIB_IMAGE="nkp-rocky-9.4-1.29.6-20240705155628"

export CERT_MANAGER_VERSION="v1.14.7"
export KOMMANDER_TEST_KUBECONFIG=kubeconfig-kommander-testing

LICENSE_STARTER_KEY="AEAAL-AAAGU-KYK79-ZGZRL-WYWU2-ULJ42-FFEEK"
LICENSE_STARTER_EMAIL="deepak.goel@nutanix.com"
#email: ZGVlcGFrLmdvZWxAbnV0YW5peC5jb20=
#nutanix-license-key: QUVBQUwtQUFBR1UtS1lLNzktWkdaUkwtV1lXVTItVUxKNDItRkZFRUs=

LICENSE_PRO_KEY="AEAAN-AAAGT-K87CM-JUHCZ-R9KMA-GN4JG-TLUCU"
LICENSE_PRO_EMAIL="kaiwalya.joshi@nutanix.com"
#email: a2Fpd2FseWEuam9zaGlAbnV0YW5peC5jb20=
#nutanix-license-key: QUVBQU4tQUFBR1QtSzg3Q00tSlVIQ1otUjlLTUEtR040SkctVExVQ1U=

LICENSE_ULTIMATE_KEY="AEAAQ-AAAGT-3YKXJ-J4BN6-D6GAS-TEE72-TNEG4"
LICENSE_ULTIMATE_EMAIL="kevin.thomas@nutanix.com"
#email: a2V2aW4udGhvbWFzQG51dGFuaXguY29t
#nutanix-license-key: QUVBQVEtQUFBR1QtM1lLWEotSjRCTjYtRDZHQVMtVEVFNzItVE5FRzQ=

create_cluster() {
  local CLUSTER_NAME=${CLUSTER_NAME:-"kjoshi-personal-cluster-$(date +%Y%m%d-%H%M%S)"}
  dkp create bootstrap
  kind get kubeconfig --name konvoy-capi-bootstrapper > kubeconfig-bootstrap

# cat <<EOF >patch.yaml
# data:
  # values.yaml: |-
    # #The Secret containing the credentials will be created by the handler.
    # createPrismCentralSecret: false
    # pcSecretName: nutanix-csi-credentials
    # supportedPCVersions: fraser-2024.1-stable-pc-0.1
# EOF
#
  # kubectl --kubeconfig kubeconfig-bootstrap patch configmap default-nutanix-csi-helm-values-template -n caren-system --type strategic --patch-file patch.yaml
  # rm patch.yaml

  # Sandalia
  # Used by Guilermo for Fit-N-Finish
  # export CONTROL_PLANE_ENDPOINT=10.41.17.254
  # dkp create cluster nutanix \
    # --self-managed=false \
    # --csi-hypervisor-attached-volumes=false \
    # --control-plane-prism-element-cluster=sandalia \
    # --control-plane-subnets=vlan141-sandalia \
    # --control-plane-endpoint-ip=${CONTROL_PLANE_ENDPOINT} \
    # --control-plane-replicas=1 \
    # --worker-prism-element-cluster=sandalia \
    # --worker-subnets=vlan141-sandalia \
    # --worker-replicas=3 \
    # --endpoint="https://prismcentral.dev.ntnxsherlock.com:9440" \
    # --csi-storage-container=default-container-900174382952 \
    # --insecure \
    # --timeout=30m0s \
    # --registry-mirror-url="https://registry-1.docker.io" \
    # --registry-mirror-username=${DOCKERHUB_READ_WRITE_USERNAME} \
    # --registry-mirror-password=${DOCKERHUB_READ_WRITE_PASSWORD} \
    # --cluster-name=${CLUSTER_NAME} \
    # --control-plane-memory=8 \
    # --worker-memory=8 \
    # --control-plane-vm-image="${NIB_IMAGE}" \
    # --worker-vm-image="${NIB_IMAGE}"

  export CONTROL_PLANE_ENDPOINT=10.41.17.253
  dkp create cluster nutanix \
    --self-managed=false \
    --csi-hypervisor-attached-volumes=false \
    --control-plane-prism-element-cluster=sandalia \
    --control-plane-subnets=vlan141-sandalia \
    --kubernetes-service-load-balancer-ip-range=${CONTROL_PLANE_ENDPOINT}-${CONTROL_PLANE_ENDPOINT} \
    --control-plane-endpoint-ip=${CONTROL_PLANE_ENDPOINT} \
    --control-plane-replicas=1 \
    --worker-prism-element-cluster=sandalia \
    --worker-subnets=vlan141-sandalia \
    --worker-replicas=3 \
    --endpoint="https://prismcentral.dev.ntnxsherlock.com:9440" \
    --csi-storage-container=default-container-900174382952 \
    --insecure \
    --timeout=30m0s \
    --registry-mirror-url="https://registry-1.docker.io" \
    --registry-mirror-username=${DOCKER_USERNAME} \
    --registry-mirror-password=${DOCKER_PASSWORD} \
    --cluster-name=${CLUSTER_NAME} \
    --control-plane-memory=8 \
    --worker-memory=8 \
    --control-plane-vm-image="${NIB_IMAGE}" \
    --worker-vm-image="${NIB_IMAGE}"

  dkp get kubeconfig -c "${CLUSTER_NAME}" > kubeconfig-kommander-testing
  #dkp create capi-components --kubeconfig kubeconfig-kommander-testing
  #dkp move capi-resources --to-kubeconfig kubeconfig-kommander-testing --from-kubeconfig kubeconfig-bootstrap
  #dkp delete bootstrap

# #Create MetalLB pool.
# cat << EOF | kubectl --kubeconfig kubeconfig-kommander-testing apply -f -
# ---
# apiVersion: metallb.io/v1beta1
# kind: IPAddressPool
# metadata:
  # name: pool
  # namespace: metallb-system
# spec:
  # addresses:
  # - ${CONTROL_PLANE_ENDPOINT}/32
# EOF

}

workload_cluster() {
  CONTROL_PLANE_ENDPOINT=${1:-"10.41.17.253"}
  CLUSTER_NAME="kjoshi-workload-cluster-$(date +%Y%m%d-%H%M%S)"
  dkp create bootstrap
  kind get kubeconfig --name konvoy-capi-bootstrapper > kubeconfig-bootstrap

# cat <<EOF >patch.yaml
# data:
  # values.yaml: |-
    The Secret containing the credentials will be created by the handler.
    # createPrismCentralSecret: false
    # pcSecretName: nutanix-csi-credentials
    # supportedPCVersions: fraser-2024.1-stable-pc-0.1
# EOF
#
  # kubectl --kubeconfig kubeconfig-bootstrap patch configmap default-nutanix-csi-helm-values-template -n caren-system --type strategic --patch-file patch.yaml
  # rm patch.yaml

  dkp create cluster nutanix \
    --self-managed=false \
    --control-plane-prism-element-cluster=sandalia \
    --control-plane-subnets=vlan141-sandalia \
    --control-plane-endpoint-ip=${CONTROL_PLANE_ENDPOINT} \
    --control-plane-replicas=1 \
    --control-plane-memory=8 \
    --worker-memory=16 \
    --worker-prism-element-cluster=sandalia \
    --worker-subnets=vlan141-sandalia \
    --worker-replicas=1 \
    --endpoint="https://prismcentral.dev.ntnxsherlock.com:9440" \
    --csi-storage-container=default-container-900174382952 \
    --insecure \
    --timeout=30m0s \
    --registry-mirror-url="https://registry-1.docker.io" \
    --registry-mirror-username=${DOCKERHUB_READ_WRITE_USERNAME} \
    --registry-mirror-password=${DOCKERHUB_READ_WRITE_PASSWORD} \
    --cluster-name=${CLUSTER_NAME} \
    --control-plane-vm-image="${NIB_IMAGE}" \
    --worker-vm-image="${NIB_IMAGE}"

  dkp get kubeconfig -c "${CLUSTER_NAME}" > kubeconfig-"${CLUSTER_NAME}"
  #dkp create capi-components --kubeconfig kubeconfig-"${CLUSTER_NAME}"
  #dkp move capi-resources --to-kubeconfig kubeconfig-"${CLUSTER_NAME}" --from-kubeconfig kubeconfig-bootstrap
  #dkp delete bootstrap
}

install_kommander() {
  #NUTANIX_LICENSE_TIER="Starter" ./hack/licensing/generate-placeholder-license.sh
  #./hack/licensing/generate-license.sh starter

  # Get or create kommander namespace
  kubectl --kubeconfig kubeconfig-kommander-testing get ns kommander || \
    kubectl --kubeconfig kubeconfig-kommander-testing create ns kommander
  # Get or create license secret
  kubectl --kubeconfig kubeconfig-kommander-testing get ns kommander || \
    kubectl --kubeconfig kubeconfig-kommander-testing get secret nutanix-license -n kommander || \
      kubectl --kubeconfig kubeconfig-kommander-testing -n kommander create secret generic nutanix-license --from-literal=nutanix-license-key=${LICENSE_STARTER_KEY} --from-literal=email=${LICENSE_STARTER_EMAIL}

  #kubectl --kubeconfig kubeconfig-kommander-testing apply -f nutanix-license-secret.yaml
  # KUBECONFIG=${KOMMANDER_TEST_KUBECONFIG} ${KD}/bin/linux/arm64/kommander install kommander \
    # --installer-config ./hack/cli-config-templates/kommander-cli-installer-config-minimal-template.yaml \
    # --kommander-applications-repository ~/repositories/kommander-applications

  KUBECONFIG=${KOMMANDER_TEST_KUBECONFIG} ./hack/install-cert-manager.sh
  KUBECONFIG=${KOMMANDER_TEST_KUBECONFIG} dkp install kommander 
}

delete_cluster() {
  CLUSTER_NAME="${1}"
  dkp create bootstrap 
  kind get kubeconfig --name konvoy-capi-bootstrapper > kubeconfig-bootstrap
  #dkp move capi-resources --from-kubeconfig kubeconfig-kommander-testing --to-kubeconfig kubeconfig-bootstrap
  dkp delete cluster --cluster-name ${CLUSTER_NAME} 
  #dkp delete bootstrap 
}

delete_hung_cluster() {
  CLUSTER_NAME="${1}"
  dkp delete cluster --cluster-name ${CLUSTER_NAME} 
  #dkp delete bootstrap 
}

main() {
  case "${1}" in
  create)
    create_cluster
    exit 0
    ;;
  delete)
    delete_cluster "${2}"
    exit 0
    ;;
  workload)
    workload_cluster "${2}"
    exit 0
    ;;
  kommander)
    install_kommander
    exit 0
    ;;
  hung)
    delete_hung_cluster "${2}"
    exit 0
    ;;
  *)
    echo "Unrecognized command: ${1}"
    exit 1
esac
}

main $@
