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

`sudo docker build -t anabelle:latest`

#### Running the container

Before running the container, create a copy of the env.vars file called env.vars.mine and fill in your azure details.

`sudo docker run --env-file env.vars.mine anabelle:latest`

## Azure Container Registry

#### Pushing the container to Azure Container Registry:
First, login to your azure container registry:

`az acr login --name [acrName]`

Next, tag the image with your registry url:

`docker tag depsvr [acrLoginUri]/depsvr`

Finally, push the image to to registry:

`docker push [acrLoginUri]/depsvr`


#### Running the container from Azure Registry:

1. Replace the variable placeholders within the `createContainer.sh` script with the correct values.
2. Login to your Azure Container Registry: `az acr login --name [acr_name]`
3. Run the script