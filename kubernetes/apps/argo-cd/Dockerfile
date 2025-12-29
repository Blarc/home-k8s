# BASED ON https://github.com/jkroepke/helm-secrets/wiki/ArgoCD-Integration#option-1-custom-docker-image

# renovate: datasource=github-releases depName=argoproj/argo-cd
ARG ARGOCD_VERSION="v3.2.3"
FROM quay.io/argoproj/argocd:$ARGOCD_VERSION
# renovate: datasource=github-releases depName=getsops/sops
ARG SOPS_VERSION=3.11.0
# renovate: datasource=github-releases depName=kubernetes/kubectl
ARG KUBECTL_VERSION=1.35.0
# renovate: datasource=github-releases depName=helmfile/vals
ARG VALS_VERSION=0.43.0
# renovate: datasource=github-releases depName=FiloSottile/age
ARG AGE_VERSION=1.3.1
# renovate: datasource=github-releases depName=jkroepke/helm-secrets
ARG HELM_SECRETS_VERSION=4.7.4

# vals or sops
ENV HELM_SECRETS_BACKEND="sops" \
    HELM_SECRETS_HELM_PATH=/usr/local/bin/helm \
    HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/" \
    HELM_SECRETS_VALUES_ALLOW_SYMLINKS=false \
    HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH=false \
    HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL=false \
    HELM_SECRETS_WRAPPER_ENABLED=false \
    HELM_PLUGINS=/gitops-tools/helm-plugins/ \
    HELM_SECRETS_CURL_PATH=/gitops-tools/curl \
    HELM_SECRETS_SOPS_PATH=/gitops-tools/sops \
    HELM_SECRETS_VALS_PATH=/gitops-tools/vals \
    HELM_SECRETS_AGE_PATH=/gitops-tools/age \
    HELM_SECRETS_KUBECTL_PATH=/gitops-tools/kubectl \
    PATH="$PATH:/gitops-tools"

# Optionally, set default gpg key for sops files
# ENV HELM_SECRETS_LOAD_GPG_KEYS=/path/to/gpg.key

USER root
RUN apt-get update && \
    apt-get install -y \
      wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /gitops-tools/helm-plugins

RUN export CURL_ARCH=$(uname -m | sed -e 's/x86_64/amd64/') \
    && wget -qO "${HELM_SECRETS_CURL_PATH}" "https://github.com/moparisthebest/static-curl/releases/latest/download/curl-${CURL_ARCH}" \
    && export GO_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/') \
    && wget -qO "${HELM_SECRETS_KUBECTL_PATH}" "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${GO_ARCH}/kubectl" \
    && wget -qO "${HELM_SECRETS_SOPS_PATH}" "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${GO_ARCH}" \
    && wget -qO- "https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${GO_ARCH}.tar.gz" | tar zxv -C "${HELM_SECRETS_VALS_PATH%/*}" vals \
    && wget -qO- "https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/helm-secrets.tar.gz" | tar -C "${HELM_PLUGINS}" -xzf- \
    && wget -qO- "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz" | tar -xzf- --strip-components=1 -C "${HELM_SECRETS_AGE_PATH%/*}" age/age \
    && chmod +x \
        "${HELM_SECRETS_CURL_PATH}" \
        "${HELM_SECRETS_SOPS_PATH}" \
        "${HELM_SECRETS_KUBECTL_PATH}" \
        "${HELM_SECRETS_VALS_PATH}" \
        "${HELM_SECRETS_AGE_PATH}" \
    && ln -sf "${HELM_PLUGINS}/helm-secrets/scripts/wrapper/helm.sh" /usr/local/sbin/helm


USER 999