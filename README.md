# Tier 3. Module 3 - MLOps CI/CD

## Homework for Topic 7 - ArgoCD for Helm deployment

### IMPORTANT NOTES:

- For instructions on deploying the full infrastructure with VPC, EKS, and ArgoCD pods, see the README.md file from branch 5.
- This README.md file only applies to Argo application deployment.
- A separate `values.yaml` file for the Argo application was chosen because it allows better scaling for large systems.
- [Bitnami NGINX](https://charts.bitnami.com/bitnami) Helm chart from ArtifactHub was chosen for its stability.

### Deploy

Connection to ArgoCD UI.

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Port-forward setup

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

sdvdg

```bash
kubectl -n argocd annotate applicationset namespaces-appset argocd.argoproj.io/application-set-refresh=force --overwrite
```
