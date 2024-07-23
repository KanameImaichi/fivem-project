# 作業手順

## 作成

```shell
bash ./deploy-vm.sh
```

## Node の追加

./deploy-vmと/ansible/hosts/k8s-servers/inventory に追記する

- [k8s-servers-wk-with-ssh]
- [k8s-servers]

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


