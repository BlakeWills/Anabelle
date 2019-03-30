#!/bin/bash

if  [ -z "$SERVER_URL" ] || \
    [ -z "$PAT" ] || \
    [ -z "$POOL" ] || \
    [ -z "$AGENT_NAME" ] || \
    [ -z "$AGENT_DIR" ] || \
    [ -z "$AZURE_SUBSCRIPTION_ID" ] || \
    [ -z "$AZURE_CLIENT_ID" ] || \
    [ -z "$AZURE_SECRET" ] || \
    [ -z "$AZURE_TENANT" ]
then
    echo "FATAL: Missing environment variables. The following must be set:"
    echo "For Azure DevOps Agent: SERVER_URL=$SERVER_URL, PAT=$PAT, POOL=$POOL, AGENT_NAME=$AGENT_NAME, AGENT_DIR=$AGENT_DIR"
    echo "For Terraform / Ansible: AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID, AZURE_CLIENT_ID=$AZURE_CLIENT_ID, AZURE_SECRET=$AZURE_SECRET, AZURE_TENANT=$AZURE_TENANT"
    
    echo

    exit 1
fi

# Set Terraform Env Vars based on Anaible vars.
export ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID
export ARM_CLIENT_ID=$AZURE_CLIENT_ID
export ARM_CLIENT_SECRET=$AZURE_SECRET
export ARM_TENANT_ID=$AZURE_TENANT

./config.sh --unattended \
    --url $SERVER_URL \
    --auth pat \
    --token $PAT \
    --pool $POOL \
    --agent $AGENT_NAME \
    --work $AGENT_DIR \
    --replace

config_exit_code=$?

if [ $config_exit_code -ne 0 ]
then
    echo "FATAL: Agent configuration failed. See output for details."
    exit $config_exit_code
fi

./run.sh