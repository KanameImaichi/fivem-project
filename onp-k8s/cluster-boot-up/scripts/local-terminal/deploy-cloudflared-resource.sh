#!/bin/bash

# region manifest URLを生成する

target_branch="$1"
k8s_definition_base_url="https://raw.githubusercontent.com/KanameImaichi/fivem-project/main"
cloudflared_k8s_endpoint_manifest_url="${k8s_definition_base_url}/onp-k8s/manifests/cluster-wide-app/cloudflared-k8s-endpoint/cloudflared-k8s-endpoint.yaml"

# endregion

# region secret リソースの中身を生成する
cloudflare_cert=$(curl -s "${k8s_definition_base_url}/k8s-proxmox/obtain-cloudflare-cert.sh" | bash -s "${target_branch}")
encoded_cert=$(echo "${cloudflare_cert}" | base64 -w 0)
cloudflare_cert_secret=$(cat <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: cluster-wide-apps
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflared-tunnel-cert
  namespace: cluster-wide-apps
type: Opaque
data:
  TUNNEL_CERT: "${encoded_cert}"
EOF
)
# endregion

# shellcheck disable=SC2029 # ssh command expanded on client side is the expected behaviour
ssh cloudinit@192.168.0.11 "cat <<EOF | kubectl apply -f -
${cloudflare_cert_secret}
EOF
"

# shellcheck disable=SC2029 # ssh command expanded on client side is the expected behaviour
#ssh cloudinit@192.168.0.11 "kubectl apply -f \"${cloudflared_k8s_endpoint_manifest_url}\""
