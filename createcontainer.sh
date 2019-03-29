#!/bin/bash

RES_GROUP='[AZURE_RESOURCE_GROUP]'
ACR_LOGIN_SERVER='[ACR_NAME].azurecr.io'
ACR_NAME='[ACR_NAME]'
AKV_NAME='[AKV_NAME]'
CONTAINER_NAME='anabelle01'
IMAGE_NAME='anabelle'
SERVER_URL=https://dev.azure.com/[YourOrganisation]
PAT='[PAT]'
POOL='default'
AGENT_NAME='anabelle01'
AGENT_DIR='usr/local/agent_work'
AZURE_SUBSCRIPTION_ID='[AZURE_SSUBSCRIPTION_ID]'
AZURE_CLIENT_ID='[AZURE_CLIENT_ID]'
AZURE_SECRET='[AZURE_SECRET]'
AZURE_TENANT='[AZURE_TENANT]'


az container create \
    --name $CONTAINER_NAME \
    --resource-group $RES_GROUP \
    --image $ACR_LOGIN_SERVER/$IMAGE_NAME:latest \
    --registry-login-server $ACR_LOGIN_SERVER \
    --registry-username $(az keyvault secret show --vault-name $AKV_NAME -n $ACR_NAME-pull-usr --query value -o tsv) \
    --registry-password $(az keyvault secret show --vault-name $AKV_NAME -n $ACR_NAME-pull-pwd --query value -o tsv) \
    --dns-name-label $CONTAINER_NAME-$RANDOM \
    --query ipAddress.fqdn \
    --environment-variables \
    'SERVER_URL'=$SERVER_URL \
    'PAT'=$PAT \
    'POOL'=$POOL \
    'AGENT_NAME'=$AGENT_NAME \
    'AGENT_DIR'=$AGENT_DIR \
    'AZURE_SUBSCRIPTION_ID'=$AZURE_SUBSCRIPTION_ID \
    'AZURE_CLIENT_ID'=$AZURE_CLIENT_ID \
    'AZURE_SECRET'=$AZURE_SECRET \
    'AZURE_TENANT'=$AZURE_TENANT