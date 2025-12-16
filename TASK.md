# Tier 3. Module 3 - MLOps CI/CD

## Homework for Topic 5 - Kubernetes for MLOps

### Technical task

In this task, we will work with two of the most important modules from the Terraform ecosystem:

- `terraform-aws-modules/vpc/aws` for creating a network

and

- `terraform-aws-modules/eks/aws` for deploying a Kubernetes cluster in AWS.

#### Objectives

- Use the modular structure of Terraform projects;
- Automate the creation of VPC and EKS using ready-made modules;
- Learn to create scalable `node groups` for CPU and GPU tasks;
- Work with `terraform_remote_state`, `outputs`, and `providers`;
- Access the cluster via `kubectl` immediately after `terraform apply`.

#### Execution results

- A full-fledged VPC infrastructure has been created in your AWS account using the official Terraform module.
- An EKS cluster with two node groups (for example, for CPU and GPU tasks) has been automatically created in this VPC.
- The project structure is modular: there are separate directories for `vpc/` and `eks/`, each with its own `variables.tf`, `outputs.tf`, `main.tf`.
- The root directory of the project contains `main.tf`, which calls both modules (`module "vpc"`, `module "eks"`).
- After `terraform apply`, the cluster is created and available via `kubectl`.
- (Bonus) If you want, you can extend the cluster with separate tags / labels for nodes or create a private cluster with access via bastion-host.

#### Task execution steps

1. Create the `vpc/` module

- Use the official `terraform-aws-modules/vpc/aws` module.
- The `vpc/` folder should contain:
- `main.tf` — with the module call;
- `variables.tf` — input parameters (CIDR, names, availability zones…);
- `outputs.tf` — export of VPC identifiers, subnets, etc.;
- `terraform.tf` and `backend.tf` — for backend configuration.

2. Create the `eks/` module

- Use the `terraform-aws-modules/eks/aws` module.
- There should be 2 `node groups`. Choose the Instance type from Free Tier: - `t2.micro` or `t3.micro`.
- Connect to the VPC created in the previous step via `data.terraform_remote_state`.

3. Root `main.tf`

- Create a `main.tf` in the root directory that imports both modules:

```shell
module "vpc" {
  source = "./vpc"
  ...
}

module "eks" {
  source = "./eks"
  ...
}
```

- All values ​​can be passed via `locals` or `variables.tf` in the root.

4. After `terraform apply`

- Verify that the cluster has been created:

```shell
aws eks --region <region> update-kubeconfig --name <your-cluster-name>
kubectl get nodes
```

- You should see both node groups.

#### Expected project structure

```shell
eks-vpc-cluster/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tf
├── backend.tf
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
└── README.md
```
