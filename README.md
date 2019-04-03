# Anabelle
Azure Provisioning Server using Docker, Terraform and Ansible, for use with Azure DevOps pipelines.

This server (container) allows you to provision resources using Terraform and configure them using Ansible.
As an added bonus, we've integrated Azure Dynamic inventory.

The primary motivation for this project was to be able seamlessly integrate Terraform and Ansible within a CI/CD pipeline, using dynamic inventory.

## Usage

Usage is pretty straight forward:

 1. Build the image
 2. Spin up an instance of the container that can connect to Azure DevOps.
 3. Create your Terraform / Ansible tasks as bash commands within a release pipeline.
 4. Ensure your pipeline runs on the correct agent. ("Run on Agent")

## Building

`Dockerfile` builds a new Azure DevOps Agent based on Centos 7 with the following installed:

- Terraform
- Ansible
- Ansible Inventory Plugin for Azure
- Python & Pip

The image can be built with a clean `docker build` command, without having to specify any configuration:

`sudo docker build -t anabelle:latest`

## Authentication

Terraform and Ansible Azure Dynamic Inventory plugin authenticate with Azure using an Azure Service Principle.

The following command can be used to create a new service principle:

`az ad sp create-for-rbac --name ServicePrincipalName`

app Id (client Id), tenant Id and password (secret) will need to be passed to the container as environment varaibles.

The Azure DevOps agent authenticates using a personal access token (PAT), which can be generated within the DevOps portal.

#### Ansible Authentication

Due to the limitations (see https://hub.docker.com/_/centos/#systemd-integration) imposed on running systemd and therefore also starting the SSH daemon within a container, Anabelle relies on password based authentication.

The server password must be specified within an ansible-vault encrypted file, this can be done by creating the file during pipeline execution, or checking the encrypted file into source control. 

## Configuration

This provisioning container requires a number of environment variables that can be specified at startup (`docker run`) or runtime (during pipeline execution).

Environment variables for the Azure DevOps agent must be supplied at startup.

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

## Azure Deployment

We recommend pushing the built image to an Azure Container Registry and deploying via an Azure Container Instance.

### Pushing the image to Azure Container Registry

First, login to your azure container registry from the command line:

`az acr login --name [acrName]`

Next, tag the image with your registry url:

`docker tag anabelle [acrLoginUri]/anabelle:latest`

Finally, push the image to to registry:

`docker push [acrLoginUri]/anabelle:latest`

### Running the container from Azure Registry:

On your local machine:

1. Replace the variable placeholders within the `createContainer.sh` script with the correct values.
2. Login to your Azure Container Registry: `az acr login --name [acr_name]`
3. Run `createContainer.sh`