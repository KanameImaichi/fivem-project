#!/bin/bash

encoded_token=$(echo "" | base64)


github_token_secret=$(cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: controller-manager
  namespace: server-list
type: Opaque
data:
  github_token: "${encoded_token}"
EOF
)
# endregion

# shellcheck disable=SC2029 # ssh command expanded on client side is the expected behaviour
ssh cloudinit@192.168.0.11 "cat <<EOF | kubectl apply -f -
${github_token_secret}
EOF
"