# Anabelle
Azure Provisioning Server using Docker, Terraform and Ansible, for use with Azure DevOps pipelines.

This server (container) allows you to provision resources using Terraform and configure them using Ansible.
As an added bonus, we've integrated Azure Dynamic inventory.

## Usage

Usage is fairly straight forward.

 1. Spin up an instance of the container that Azure DevOps can see.
 2. Create your Terraform / Ansible tasks as bash commands within a release pipeline.
 3. Ensure your release runs on your agent. ("Run on Agent")

 // TODO: Make this better.  

## Building

`Dockerfile` builds a new Azure DevOps Agent based on Centos 7 with the following installed:

- Terraform
- Ansible
- Ansible Inventory Plugin for Azure
- Python & Pip

### TLDR:

 - Create an Azure Service Principal to authenticate with Azure.
 - Generate a PAT within Azure DevOps for the agent.
 - Build the image

#### Create a Service Principal
`az ad sp create-for-rbac --name ServicePrincipalName`

Take note of the app Id, tenant Id and password.

#### Building the container:

`sudo docker build -t anabelle:latest`

## Configuration

| Variable Name  | Required By | Description  | Startup  | Runtime  |
|---|---|---|---|---|
| SERVER_URL  | Azure DevOps Agent  | Azure Organisation Url, E.G: https://dev.azure.com/[YourOrg]/  | :heavy_check_mark:  | :x:  |
| PAT  | Azure DevOps Agent  | Personal Access Token  | :heavy_check_mark:  | :x:   |
| POOL  | Azure DevOps Agent  | Agent Pool Name  | :heavy_check_mark:  | :x:  |
| AGENT_NAME  | Azure DevOps Agent  | Agent Name  | :heavy_check_mark:  | :x:  |
| AGENT_DIR  | Azure DevOps Agent  | Working Directory for the Agent   | :heavy_check_mark:  | :x:  |
| AZURE_SUBSCRIPTION_ID  | Ansible  | Your Azure Subscription Id  | :heavy_check_mark:  |:heavy_check_mark: |
| AZURE_CLIENT_ID  | Ansible  | Client Id for the Azure Service Principle   | :heavy_check_mark:  |:heavy_check_mark: |
| AZURE_SECRET  | Anisble  | Azure Service Principle Secret    | :heavy_check_mark:  |:heavy_check_mark: |
| AZURE_TENANT  | Ansible  | Azure Service Principle Tenant Id    | :heavy_check_mark:  |:heavy_check_mark: |
| ARM_SUBSCRIPTION_ID  | Terraform  | Your Azure Subscription Id   | :heavy_check_mark:  |:heavy_check_mark: |
| ARM_CLIENT_ID  | Terraform  | Client Id for the Azure Service Principle  | :heavy_check_mark:  |:heavy_check_mark: |
| ARM_CLIENT_SECRET  | Terraform  | Azure Service Principle Secret  | :heavy_check_mark:  |:heavy_check_mark: |
| ARM_TENANT_ID  | Terraform  | Azure Service Principle Tenant Id | :heavy_check_mark:  |:heavy_check_mark: |

Note: Specifiying the Ansible variables at container startup will also set the Terraform variables with matching values.

## Local Deployment

Before running the container, create a copy of the env.vars file called env.vars.mine and fill in your azure details.

`sudo docker run --env-file env.vars.mine anabelle:latest`

### Azure Deployment

We recommend pushing the built image to an Azure Container Registry and deploying via an Azure Container Instance.

#### Pushing the image to Azure Container Registry

First, login to your azure container registry from the command line:

`az acr login --name [acrName]`

Next, tag the image with your registry url:

`docker tag anabelle [acrLoginUri]/anabelle:latest`

Finally, push the image to to registry:

`docker push [acrLoginUri]/anabelle:latest`


#### Running the container from Azure Registry:

1. Replace the variable placeholders within the `createContainer.sh` script with the correct values.
2. Login to your Azure Container Registry: `az acr login --name [acr_name]`
3. Run the script