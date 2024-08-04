#!/bin/bash

# region manifest URLを生成する

target_branch="$1"
k8s_definition_base_url="https://raw.githubusercontent.com/KanameImaichi/fivem-project/main"
cloudflared_k8s_endpoint_manifest_url="${k8s_definition_base_url}/k8s-manifests/apps/cluster-wide-apps/cloudflared-k8s-endpoint/cloudflared-k8s-endpoint.yaml"
# endregion

# region secret リソースの中身を生成する
cloudflare_cert_pem="$(/bin/bash <(curl -s "${k8s_definition_base_url}/k8s-proxmox/obtain-cloudflared-cert.sh") "${target_branch}")"

prerequisite_resources="$(cat <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: cloudflared-tunnel-exits
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflared-tunnel-credential
  namespace: cloudflared-tunnel-exits
type: Opaque
data:
  TUNNEL_CREDENTIAL: "$(echo "${cloudflare_cert_pem}" | base64 -w 0 -)"
EOF
)"
# endregion

# shellcheck disable=SC2029 # ssh command expanded on client side is the expected behaviour
ssh 192.168.0.11 "
cat <<EOF | kubectl apply -f -
${prerequisite_resources}
EOF
"

# shellcheck disable=SC2029 # ssh command expanded on client side is the expected behaviour
ssh 192.168.0.11 "kubectl apply -f \"${cloudflared_k8s_endpoint_manifest_url}\""
