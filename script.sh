# ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

pacman -S age
age-keygen -o age.agekey
cat age.agekey | kubectl create secret generic sops-age --namespace argocd --from-file=keys.txt=/dev/stdin

# Kustomize ksops variant
pacman -S kustomize sops

curl -s https://raw.githubusercontent.com/viaduct-ai/kustomize-sops/master/scripts/install-ksops-archive.sh | sudo bash

sops --encrypt secret.yaml > secret.enc.yaml

kustomize build --enable-alpha-plugins --enable-exec .

# Helm secrets variant
pacman -S helm sops
helm plugin install https://github.com/jkroepke/helm-secrets --version v4.6.0

helm secrets encrypt secret.yaml > secret.enc.yaml
helm secrets decrypt secret.enc.yaml

helm template -f secrets://secret.enc.yaml .

kubectl apply -f argocd-cm-patch.yaml
kubectl patch deployment -n argocd argocd-repo-server --patch-file argocd-deployment-patch.yaml
