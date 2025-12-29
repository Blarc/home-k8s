# Argo CD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

## Installation

Argo CD should be installed using command `helm template`, because Argo CD is configured to manage itself and that is
what it uses to deploy Helm charts:

```bash
# First install CRDS
helm template argo-cd . -f secrets://values.encrypted.yaml --set argo-cd.crds.install=true | yq '. | select(.kind == "CustomResourceDefinition")' | kubectl apply -f -
# Then install the rest of the chart
helm template argo-cd . -n argo-cd -f secrets://values.encrypted.yaml | kubectl apply -f -
```

### Access to other clusters

The access is configured via cluster secrets, but cluster roles (on target clusters) are not created automatically. The
easiest way to create them is to use command:
```bash
argocd cluster add <context> --cluster-resources=true
```

## SOPS

To use SOPS with Argo CD, you need to encrypt the `values.yaml` file with the following public key:

```
age10ke2vw8xe8rjlr6wad6wscze3ule7k3yryzxp79vs8j74r28t9kqz8fp6m
```

## Migrate from one cluster to another

Based on https://faun.pub/smoothly-migrating-argo-cd-to-a-new-cluster-a-step-by-step-guide-1c93c96358f7

1. Take a screenshot of the existing Argo CD UI
2. Scale all Argo's deployments to 0.
3. Make sure you commited all changes of Argo CD Helm chart to git.
4. Deploy Argo CD on a new cluster.