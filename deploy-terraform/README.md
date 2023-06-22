## Access AKS

```
az aks get-credentials --resource-group $(terraform output rg_name) --name $(terraform output aks_name)
```
