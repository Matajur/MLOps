# Tier 3. Module 3 - MLOps CI/CD

## Homework for Topic 9 - Monitoring the quality of models and tracking experiments

### Technical task

Now it's time to move on to the **quality of the model itself** — tracking experiments, parameters, results, and automatic analysis. We will learn:

- Carry out a series of launches with different parameters;
- Determine the best model;
- Display results not only in MLflow, but also in Grafana (via PushGateway + Prometheus).

This project will be a great addition to your portfolio as an **MLOps engineer** who builds not just pipelines, but **controlled systems for model analysis**.

#### The goal

- Track ML experiments through MLflow;
- Log parameters, metrics, artifacts;
- Automatically choose the best model;
- Output key metrics of the experiment in Grafana via PushGateway;
- Deploy all services declaratively through **ArgoCD**.

#### Task performance steps

1. Deploy the MLflow infrastructure via ArgoCD

In the repository with ArgoCD configurations, create:

- `application.yaml` for MinIO from bucket `mlflow-artifacts`;
- `application.yaml` for PostgreSQL with `mlflow` base;
- `application.yaml` for MLflow Tracking Server (`ClusterIP`, port 5000).
- Verify that MLflow is available via kubectl port-forward.

2. Deploy Prometheus PushGateway via ArgoCD

Create an `application.yaml` for:

- Helm-chart `prometheus-pushgateway`;
- Namespace — `monitoring`;
- The service should be `ClusterIP`, port `9091`.

After that, PushGateway will be available at:
`http://pushgateway.monitoring.svc.cluster.local:9091`

3. Write the Python script `train_and_push.py`

The script should:

- Download a dataset (for example, Iris);
- Complete a training cycle with different parameters (`learning_rate`, `epochs`);
- For each run:
  - Log parameters and metrics in MLflow;
  - Save the model as an artifact;
  - Push `accuracy` and `loss` to PushGateway with `run_id` labels;
- After completion:
  - Find the launch with the best `accuracy`;
  - Copy the model to the local directory `best_model/`.

4. View the metrics in Grafana

In Grafana → Explore → Prometheus check:

- `mlflow_accuracy`
- `mlflow_loss`
- Build graphs or a tabular view.

5. README.md should contain:

- How to run `train_and_push.py`;
- How to check the presence of MLflow and PushGateway in the cluster;
- How to `port-forward`;
- How to view metrics in Grafana;
- Links to MLflow UI and Grafana Explore screenshots.

#### Expected structure of the project:

```bash
mlops-experiments/
├── argocd/
│   ├── applications/
│   │   ├── mlflow.yaml
│   │   ├── minio.yaml
│   │   ├── postgres.yaml
│   │   └── pushgateway.yaml
├── experiments/
│   ├── train_and_push.py
│   └── requirements.txt
├── best_model/
│   └── <model> # will appear after successful launch
└── README.md
```
