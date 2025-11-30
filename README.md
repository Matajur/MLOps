## Repository for MLOps CI/CD Homeworks

See separate branches for aech homework.

This code is needed to create an S3 bucket to store `tfstate` (infrastructure state).

#### Instructions:

- comment out the code in `backend.tf`;
- execute the following commands, which will create an S3 bucket with an empty `terraform.tfstate` to store the state:

```bash
terraform init
terraform plan
terraform apply
```

- uncomment out the code in `backend.tf`;
- execute the following command, which will transfer the current state to the `terraform.tfstate` file:

```bash
terraform init
```
