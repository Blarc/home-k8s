# Argo CD
## Connect with GitHub App
1. Go to https://github.com/settings/apps and create new GitHub App.
2. Set permission for **Content** to `Read-Only`
3. Install the app to your GitHub account and choose the repository you'd like to use.
4. Go to https://github.com/settings/installations, click on your installation and remember the installation ID from the url e.g `https://github.com/settings/installations/<installation-id>`.
5. Generate new Private key from the GitHub App settings page.
6. Login to argo-cd
   ```bash
   # Retrieve admin password
   argocd admin initial-password -n argo-cd # change namespace if needed
   argocd login # username: admin, password: from previous command
   ```
7. Run the following command to add the repo:
   ```bash
   argocd repo add https://github.com/Blarc/home-k8s --github-app-id <app-id> --github-app-installation-id <installation-id> --github-app-private-key-path <example.private-key.pem>
   ```
## KSOPS
1. Install KSOPS as custom tooling in Argo CD helm chart by following [instructions](https://github.com/viaduct-ai/kustomize-sops?tab=readme-ov-file#argo-cd-helm-chart-with-custom-tooling).
2. Create a secret containing the key and add it to Argo CD by following [instructions](https://github.com/viaduct-ai/kustomize-sops?tab=readme-ov-file#argocdgitops-operator-w-ksopsagekey-in-okd4ocp4).
