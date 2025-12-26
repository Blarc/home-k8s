# Authentik

## Recover password
Execute the following command:
```bash
kubectl exec -it deployment/authentik-worker -c worker -- ak create_recovery_key 10 akadmin
```