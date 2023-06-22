# Deployment for perftest
Deployment using terraform in Azure subscription.

Resources structured into following resource groups
- Network
- Web
- App
- Data databases
- Data services
- Monitor

## Prepare your workstation

Instructions for deployment
- Install AZ CLI 
- Install Terraform

## Deploy
Deployment use az command to build container in Azure ACR.

```bash
az login

terraform init
terraform apply
```

## Access AKS

```bash
az aks get-credentials --resource-group $(terraform output aks_rg_name) --name $(terraform output aks_name)
```

## Access VMs
Use Azure Bastion in network resource group (if variable changed)

## Destroy
Warning: resource groups will be deleted automatically, ignoring manually created resources 

```bash
terraform destroy
```
