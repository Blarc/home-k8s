```bash
kubectl get wireguardpeer blarc --template={{.status.config}} | bash | qrencode -t ansiutf8
```
