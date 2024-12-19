# Cert Manager

## Installation

```bash
kustomize build --enable-helm . | k apply -f -
```


## Useful
```bash
kubectl api-resources --verbs=list --namespaced -o name  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n cert-manager
```

If you delete cert-manager namespace, challenges might be stuck. You need to:
```bash
k delete validatingwebhookconfigurations.admissionregistration.k8s.io release-name-cert-manager-webhook
k delete mutatingwebhookconfigurations.admissionregistration.k8s.io release-name-cert-manager-webhook
```
And then you can patch the finalizers
```bash
k patch challenge.acme.cert-manager.io/example-cert-1-2013233382-2636552871  --type json --patch='[ {"op": "remove", "path": "/metadata/finalizers" } ]'
```
