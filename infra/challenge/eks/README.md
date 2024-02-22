# Initialize terraform with remote state

```bash
terraform init
```

```bash
terraform plan -out eks.tfplan -var-file=environment/dev.tfvars
```

```bash
terraform apply "eks.tfplan"
```


## EKS operations

add context
```
aws eks update-kubeconfig --name <cluster_name> --region us-east-1 --profile <aws-profile>
```