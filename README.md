# 作業手順

## 作成
```shell
bash ./deploy-vm.sh
```

## ArgoCDの設定
外部からアクセスできるように変更
```shell
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
初期パスワードの取得
```shell
kubectl -n argocd get secret/argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```


