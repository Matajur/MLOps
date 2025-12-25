# Lesson 8-9: MLflow + Pushgateway via ArgoCD

This branch contains GitOps manifests and an experiment script that:

- Deploys MinIO, PostgreSQL, and an MLflow Tracking Server via ArgoCD;
- Deploys Prometheus Pushgateway via ArgoCD;
- Runs a small hyperparameter sweep on Iris and:
  - logs params/metrics/artifacts to MLflow;
  - pushes `mlflow_accuracy` and `mlflow_loss` to Pushgateway with `run_id` labels;
  - downloads the best model to `best_model/`.

## Repo structure

```
MLOps/
├── argocd/
│   ├── applications/
│   │   ├── mlflow.yaml
│   │   ├── minio.yaml
│   │   ├── postgres.yaml
│   │   └── pushgateway.yaml
│   └── manifests/
│       └── mlflow/
│           ├── deployment.yaml
│           ├── service.yaml
│           └── secret.yaml
├── experiments/
│   ├── train_and_push.py
│   └── requirements.txt
├── best_model/
│   └── <downloaded model artifacts appear here after running>
└── README.md
```

## 1) Deploy MLflow infra via ArgoCD

Apply the applications to the ArgoCD namespace (adjust `-n argocd` if your ArgoCD lives elsewhere):

```bash
kubectl apply -n argocd -f argocd/applications/minio.yaml
kubectl apply -n argocd -f argocd/applications/postgres.yaml
kubectl apply -n argocd -f argocd/applications/mlflow.yaml
```

The MLflow server is exposed as a `ClusterIP` service in `mlflow` namespace (port `5000`).

Verify via port-forward:

```bash
kubectl -n mlflow port-forward svc/mlflow 5000:5000
curl -I http://localhost:5000
```

## 2) Deploy Prometheus Pushgateway via ArgoCD

```bash
kubectl apply -n argocd -f argocd/applications/pushgateway.yaml
```

Pushgateway will be available in-cluster at:

- `http://pushgateway.monitoring.svc.cluster.local:9091`

## 3) Run training and push metrics

From the repo root:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r experiments/requirements.txt

# In a separate terminal: keep port-forward active
kubectl -n mlflow port-forward svc/mlflow 5000:5000

python experiments/train_and_push.py \
  --tracking-uri http://localhost:5000 \
  --pushgateway http://pushgateway.monitoring.svc.cluster.local:9091
```

After completion, the best model artifacts will be downloaded into `best_model/`.

## 4) View metrics in Grafana

In **Grafana → Explore → Prometheus**, query:

- `mlflow_accuracy`
- `mlflow_loss`

Use table or time series view. Each pushed sample is labelled with `run_id`.
