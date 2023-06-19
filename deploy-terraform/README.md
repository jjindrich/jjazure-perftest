# Deployment steps

  - Apply Terraform
  - Build ACR image
  - Deploy AKS
  - Update tfvars with AKS IP
  - apply terraform again to update haproxy configuration

## ACR

```
az acr build -t perftest:v2 -r $(terraform output acr_name) https://github.com/jjindrich/jjazure-perftest.git -f PerfTest\Dockerfile --platform linux
```

## Deploy to AKS

```
az aks get-credentials --resource-group placeholder2 --name testing-k8s

kubectl create namespace perftest

$result = az acr token create --name aci-access --registry $(terraform output acr_name) --scope-map _repositories_pull --output json
$response = $result | ConvertFrom-Json
kubectl --namespace=perftest create secret docker-registry regcred --docker-server=testingacr1432.azurecr.io --docker-username=$($response.credentials.username) --docker-password=$($response.credentials.passwords[0].value) --docker-email="test@test.cz"

kubectl apply -f aks/deploy-aks-deployment.tf

```

get service IP 
```
kubectl --namespace perftest get service perftest-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

and update this IP in `terraform.tfvars` 


## Notes

### SSH to VMs

#### prereqs
```
az extension add -n ssh
```

Get SSH Key:
```
terraform output -raw private_key > private_key.pem
```
