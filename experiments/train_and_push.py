"""Module to train a simple model, log runs to MLflow, and push metrics to Prometheus Pushgateway.

Notes:
  - For MLflow on Kubernetes, use port-forward:
      kubectl -n mlflow port-forward svc/mlflow 5000:5000
  - Pushgateway is expected at:
      http://pushgateway.monitoring.svc.cluster.local:9091
  - Usage example:
      python experiments/train_and_push.py \
        --tracking-uri http://localhost:5000 \
        --pushgateway http://pushgateway.monitoring.svc.cluster.local:9091
"""

from __future__ import annotations

import argparse
import os
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import mlflow
from mlflow.tracking import MlflowClient

import numpy as np
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway
from sklearn.datasets import load_iris
from sklearn.linear_model import SGDClassifier
from sklearn.metrics import accuracy_score, log_loss
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler


@dataclass(frozen=True)
class RunConfig:
    learning_rate: float
    epochs: int


def iter_configs() -> Iterable[RunConfig]:
    lrs = [0.001, 0.01, 0.05, 0.1]
    epochs = [10, 30, 60, 120]
    for lr in lrs:
        for ep in epochs:
            yield RunConfig(learning_rate=lr, epochs=ep)


def push_metrics(
    pushgateway_url: str, run_id: str, accuracy: float, loss: float
) -> None:
    """Push two gauges with run_id label to Pushgateway."""
    registry = CollectorRegistry()

    g_acc = Gauge(
        "mlflow_accuracy",
        "Model accuracy for an MLflow run",
        labelnames=("run_id",),
        registry=registry,
    )
    g_loss = Gauge(
        "mlflow_loss",
        "Model loss (log loss) for an MLflow run",
        labelnames=("run_id",),
        registry=registry,
    )

    g_acc.labels(run_id=run_id).set(float(accuracy))
    g_loss.labels(run_id=run_id).set(float(loss))

    # grouping_key keeps metrics separate per run_id (visible in /metrics on Pushgateway)
    push_to_gateway(
        pushgateway_url,
        job="mlflow-training",
        registry=registry,
        grouping_key={"run_id": run_id},
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--tracking-uri",
        default=os.environ.get("MLFLOW_TRACKING_URI", "http://localhost:5000"),
        help="MLflow tracking URI (default: http://localhost:5000)",
    )
    parser.add_argument(
        "--experiment-name",
        default=os.environ.get("MLFLOW_EXPERIMENT_NAME", "lesson-8-9"),
        help="MLflow experiment name",
    )
    parser.add_argument(
        "--pushgateway",
        default=os.environ.get(
            "PUSHGATEWAY_URL", "http://pushgateway.monitoring.svc.cluster.local:9091"
        ),
        help="Pushgateway URL",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Random seed",
    )

    args = parser.parse_args()

    mlflow.set_tracking_uri(args.tracking_uri)
    mlflow.set_experiment(args.experiment_name)

    X, y = load_iris(return_X_y=True)
    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.25,
        random_state=args.seed,
        stratify=y,
    )

    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)

    classes = np.unique(y_train)

    for cfg in iter_configs():
        with mlflow.start_run(
            run_name=f"lr={cfg.learning_rate}_ep={cfg.epochs}"
        ) as run:
            run_id = run.info.run_id

            # Log hyperparameters
            mlflow.log_param("learning_rate", cfg.learning_rate)
            mlflow.log_param("epochs", cfg.epochs)

            # Model: multinomial logistic regression via SGD
            clf = SGDClassifier(
                loss="log_loss",
                learning_rate="constant",
                eta0=cfg.learning_rate,
                penalty="l2",
                alpha=0.0001,
                random_state=args.seed,
            )

            # Train for 'epochs' using partial_fit to simulate a training loop.
            for _ in range(cfg.epochs):
                clf.partial_fit(X_train, y_train, classes=classes)

            # Evaluate
            proba = clf.predict_proba(X_test)
            y_pred = np.argmax(proba, axis=1)
            acc = float(accuracy_score(y_test, y_pred))
            loss = float(log_loss(y_test, proba))

            # Log metrics
            mlflow.log_metric("accuracy", acc)
            mlflow.log_metric("loss", loss)

            # Log artifacts (scaler + model) using MLflow's sklearn flavor
            mlflow.sklearn.log_model(sk_model=clf, name="model")
            mlflow.sklearn.log_model(sk_model=scaler, name="scaler")

            # Push to Pushgateway with run_id label
            push_metrics(args.pushgateway, run_id=run_id, accuracy=acc, loss=loss)

            print(
                f"run_id={run_id} lr={cfg.learning_rate} epochs={cfg.epochs} accuracy={acc:.4f} loss={loss:.4f}"
            )

    # Pick best run by accuracy and copy its model artifacts to ./best_model/
    client = MlflowClient()
    exp = client.get_experiment_by_name(args.experiment_name)
    if exp is None:
        raise RuntimeError(f"Experiment not found: {args.experiment_name}")

    runs = client.search_runs(
        experiment_ids=[exp.experiment_id],
        order_by=["metrics.accuracy DESC"],
        max_results=1,
    )
    if not runs:
        raise RuntimeError("No runs found to select best model")

    best_run = runs[0]
    best_run_id = best_run.info.run_id
    best_acc = best_run.data.metrics.get("accuracy")

    dst_root = Path("best_model")
    dst_root.mkdir(parents=True, exist_ok=True)

    # Clean existing output to keep the directory deterministic
    for child in dst_root.iterdir():
        if child.is_dir():
            shutil.rmtree(child)
        else:
            child.unlink()

    # Download the 'model' artifact directory into best_model/
    downloaded_path = client.download_artifacts(
        best_run_id, "model", dst_path=str(dst_root)
    )

    print(f"\nBest run: {best_run_id} accuracy={best_acc}")
    print(f"Model copied to: {downloaded_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
