# Deployment steps

  - Apply Terraform
  - ~~Build ACR image~~ - part of TF
  - ~~Deploy to AKS~~ - part of TF
  - ~~Update tfvars with AKS IP~~ - part of TF
  - ~~apply terraform again to update haproxy configuration~~ - part of TF

## ACR
not needed anymore as is part of deployment to ACR, but useful to push newer version after initial tf deploy.
```
az acr build -t perftest:v2 -r $(terraform output acr_name) https://github.com/jjindrich/jjazure-perftest.git -f PerfTest\Dockerfile --platform linux
```

## Access AKS

```
az aks get-credentials --resource-group $(terraform output rg_name) --name $(terraform output aks_name)
```

### create access token and store as secret
happens as part of TF deploy.

```
$result = az acr token create --name aci-access --registry $(terraform output acr_name) --scope-map _repositories_pull --output json
$response = $result | ConvertFrom-Json
kubectl --namespace=perftest create secret docker-registry regcred --docker-server=testingacr1432.azurecr.io --docker-username=$($response.credentials.username) --docker-password=$($response.credentials.passwords[0].value) --docker-email="test@test.cz"

```

get service IP of load balanced service
```
kubectl --namespace perftest get service perftest-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```


## Misc

### SSH key to access

Get SSH Key:
```
terraform output -raw private_key > private_key.pem
```
