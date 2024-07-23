# 作業手順

## 作成

```shell
bash ./deploy-vm.sh
```

## Node の追加

./deploy-vmと/ansible/hosts/k8s-servers/inventory に追記する

## ArgoCDの設定

LBのポートを確認する

```shell
kubectl get services -n argocd
```

初期パスワードの取得
adminでログイン

```shell
kubectl -n argocd get secret/argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```


