# Anabelle
Azure Provisioning Server using Docker, Terraform and Ansible, for use with Azure DevOps.

## Building

`Dockerfile` builds a new Azure DevOps Agent based on Centos 7 with the following installed:

- Terraform
- Ansible
- Ansible Inventory Plugin for Azure
- Python & Pip

### TLDR:

 - Generate a new SSH key pair for Ansible authentication on your new machines.
 - Create an Azure Service Principal to authenticate with Azure.
 - Generate a PAT within Azure DevOps for the agent.
 - Build the image

#### Create a Service Principal
`az ad sp create-for-rbac --name ServicePrincipalName`

Take note of the app Id, tenant Id and password.

#### Generating a new SSH key for the server:
To use SSH authentication with Ansible, you can supply a new key pair in the form of `id_rsa` and `id_rsa.pub` files. Use `ssh-keygen` to generate the new keys.

Place both files in the same directory as Dockerfile.


#### Building the container:

```    
sudo docker build -t depsvr:latest \
    --build-arg SERVER_URL=[AzureDevOpsOrgUrl] \
    --build-arg PAT=[PersonalAccessToken] \
    --build-arg AGENT_NAME=[AgentName] \
    --build-arg AGENT_DIR=usr/local/agent_work
    --build-arg AZURE_SUB_ID=[SubscriptionId] \
    --build-arg AZURE_CLIENT_ID=[ClientId] \
    --build-arg AZURE_SECRET=[Secret] \
    --build-arg AZURE_TENANT=[Tenant] .
```

#### Running the container



## Azure Container Registry

#### Pushing the container to Azure Container Registry:
First, login to your azure container registry:

`az acr login --name [acrName]`

Next, tag the image with your registry url:

`docker tag depsvr [acrLoginUri]/depsvr`

Finally, push the image to to registry:

`docker push [acrLoginUri]/depsvr`


#### Running the container from Azure Registry:

```
export RES_GROUP=[ResourceGroupName]
export ACR_LOGIN_SERVER=[AcrLoginServer]
export ACR_NAME=[AcrName]
export AKV_NAME=[AzureKeyVaultName]

az container create \
    --name [containerName] \
    --resource-group $RES_GROUP \
    --image $ACR_LOGIN_SERVER/depsvr:latest \
    --registry-login-server $ACR_LOGIN_SERVER \
    --registry-username $(az keyvault secret show --vault-name $AKV_NAME -n $ACR_NAME-pull-usr --query value -o tsv) \
    --registry-password $(az keyvault secret show --vault-name $AKV_NAME -n $ACR_NAME-pull-pwd --query value -o tsv) \
    --dns-name-label aci-demo-$RANDOM \
    --query ipAddress.fqdn
```



ENV AZURE_SUBSCRIPTION_ID
ENV AZURE_CLIENT_ID
ENV AZURE_SECRET=${AZURE_SECRET}
ENV AZURE_TENANT=${AZURE_TENANT}