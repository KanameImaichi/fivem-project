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
   ssh 192.168.0.11 "cat ~/.kube/config" 
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
## Cloudflare Tunnel
1. Cloudflaredに必要な tunnel certをsecretとして注入する。
```shell
/bin/bash <(curl -s "https://raw.githubusercontent.com/KanameImaichi/fivem-project/main/k8s-proxmox/deploy-cloudflared-resource.sh") "main"
```
1. GitHub Actions で実行される terraform コマンドの実行に必要な `kubeconfig` を `seichi_infra` リポジトリの Actions secrets として設定します。

   https://github.com/KanameImaichi/fivem-project/settings/secrets/actions にアクセスし `Repository secrets > TF_VAR_ONP_K8S_KUBECONFIG` に下記コマンドの標準出力を注入してください。
    ```bash
    ssh seichi-onp-k8s-cp-1 "cat ~/.kube/config" 
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