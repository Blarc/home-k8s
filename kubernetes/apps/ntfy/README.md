# Ntfy

## Generate user password
To generate a password for Ntfy, use the following command:
```bash
kubectl exec -it statefulsets/ntfy -n ntfy -- ntfy user hash
```
