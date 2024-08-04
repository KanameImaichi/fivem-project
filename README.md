# 作業手順

## ProxmoxでのVMの作成

```shell
bash ./deploy-vm.sh
```

## Node の追加

./deploy-vmと/ansible/hosts/k8s-servers/inventory に追記する

- [k8s-servers-wk-with-ssh]
- [k8s-servers]

## セットアップ

1. k8s API endpoint へのインターネットからの経路を確立するために、 cloudflared-tunnel-credential Secret を作成します。

    ```bash
    /bin/bash <(curl -s "https://raw.githubusercontent.com/KanameImaichi/fivem-project/main/k8s-proxmox/deploy-k8s-api-cloudflared-resources-to-cp-1.sh") "main"
    ```

   ```bash
   ssh seichi-onp-k8s-cp-1 "cat ~/.kube/config" 
   ```

## ArgoCD

すべてのサービスをargocdを使って管理している。

### ログインする

ロードバランサに割り当てられたポートを確認する
nodeがreadyになってからすべてのサービスがデプロイされるまでに5分ほどかかるため、表示されるまで待つ。

```shell
kubectl get services -n argocd
```

デプロイがうまくいっていない場合、アクセスできないので以下のコマンドを使う。

```shell
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

### 初期パスワードの取得

ユーザーー名はadmin
パスワードは以下のコマンドで確認する。

```shell
kubectl -n argocd get secret/argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

# External Secret Operator

GCPのSecretManagerでGithub Actions Self Hosted などのSecretの管理取得を行っている。
サービスアカウントキーを使用してGCPへの認証を行うためSecretを追加する。

```shell
kubectl create namespace server-list
kubectl apply -f gcpsm-secret.yaml -n server-list 
```

サンプルは以下の通り。

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gcpsm-secret
  namespace: external-secrets
  labels:
    type: gcpsm
type: Opaque
stringData:
  secret-access-credentials: |
    {
    "YOUR JSON SERVICE ACCOUNT KEY"
    }


```

# Grafana

以下のコマンドでパスワードを取得する

```shell
kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-user}' | base64 -d; echo
kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```

# Special Thanks

https://github.com/GiganticMinecraft/seichi_infra