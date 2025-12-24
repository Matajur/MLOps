# Tier 3. Module 3 - MLOps CI/CD

## Homework for Topic 7 - ArgoCD for Helm deployment

### Technical task

You already know how to create a cluster in AWS using Terraform, work with kubectl and Helm. It's time to take it a step further - **deploy services via Git** using **ArgoCD**.

#### Objective

- Deploy ArgoCD in Kubernetes using Terraform;
- Create a Git repository with Helm deployment (**MLflow**);
- Create an ArgoCD Application that will automatically pick up this application;
- Make sure that the cluster deploys pods automatically from Git.

#### Task execution steps

1. Deploy ArgoCD via Terraform

- In the EKS cluster you have already created, deploy ArgoCD as a Helm release via Terraform.
- Create a separate namespace (e.g. `infra-tools`).
- Put all the values ​​for the AgroCD chart in the file `argocd-values.yaml`.

Check:

```bash
kubectl get pods -n infra-tools
```

There should be several pods with the prefix `argocd-`.

Expected structure:

```bash
terraform/
└── argocd/
    ├── main.tf
    ├── variables.tf
    ├── provider.tf
    ├── outputs.tf
    ├── terraform.tf
    ├── backend.tf
    └── values/
        └── argocd-values.yaml
```

**NOTE: for Argo CD deployment infrastracture see the updated branch 5.**

2. Create a separate Git repository with Helm deployment

Create a new repository

- Name (example): `argocd-repo`
- Visibility: Public recommended
- Initialize README.md

```bash
goit-argo
├── namespaces
│ ├── application
│ │ ├── nginx.yaml
│ │ └── ns.yaml
│ └── infra-tools
│   └── ns.yaml
└── README.md
```

3. Create ArgoCD Application

Where to find Helm chart:

    - Search for the chart in ArtifactHub (name, version, repo URL) or on GitHub projects (charts/ section or Helm repo itself).
    - From there you take:

- `repoURL` (URL of Helm repository),
- `chart` (chart name),
- `targetRevision` (chart version),
- example `values.yaml` (this is not an Argo manifest, just overrides for Helm).

How to convert `values` ​​to Argo Application:

- Your values ​​need to be embedded in Argo Application as Helm source. There are two ways:

Option A — `inline values:`

In `Application`, add a section `spec.source.helm.values: |` and insert your overrides there (from ArtifactHub).

Option B — a separate `values.yaml` file:

Put `values.yaml` in your Git repository and reference it via `spec.source.helm.valueFiles` (e.g. `values/mlflow-values.yaml`).

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: <argocd-namespace> # where ArgoCD is deployed (for ex., infra-tools)
spec:
  project: default
  source:
    repoURL: <helm-repo-url> # з ArtifactHub or GitHub Helm repo
    chart: <chart-name> # chart name
    targetRevision: <chart-version>
    helm:
      # CHOOSE ONE WAY:
      # values: |         # ← paste your overrides here (Option A)
      #  ...
      # valueFiles:        # ← or link to a file in your Git (Option B)
      #  - values/<file>.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: <target-namespace> # where to deploy the application
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

4. Add the Application to the cluster

- Create an `application.yaml` file in your Git repository with a description of the ArgoCD Application (see the previous step).
- Commit the changes and do a `git push` to the `main` branch.
- ArgoCD will automatically pick up the new Application from the repository.
- Check in the ArgoCD web interface (or via command):

```bash
kubectl get applications -n <argocd-namespace>
```

Wait for synchronization and make sure that pods have appeared in the corresponding namespace:

```bash
kubectl get pods -n <target-namespace>
```

5. Open access to the service

- Either via `kubectl port-forward` or via LoadBalancer.
- Add instructions to README.md.
