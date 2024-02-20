# Helm template for basic rails application

this template was created with the next command
```bash
helm create helm-rails
```
all the yaml`s files in the template folder were deleted except by deployment.yaml and service.yaml and contains the minimum functionality to deploy the rails application

all the variables by environment are stored in `environments` folder 

to deploy the helm template to k8s just run the next command
```bash
helm install -f values.yaml --namespace default --values environments/dev.yaml local-rails .
```

to update use upgrade

```bash
helm upgrade -f values.yaml --namespace default --values environments/dev.yaml local-rails .
```