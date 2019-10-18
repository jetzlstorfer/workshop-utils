#!/bin/bash

# load in the shared library and validate argument
source ../common.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
CLUSTER_NAME="$RESOURCE_PREFIX"-keptn-workshop-cluster

clear 
case $DEPLOYMENT in
  eks)
    CLUSTER_REGION=$(cat creds.json | jq -r '.eksClusterRegion')

    echo "===================================================="
    echo "About to delete $DEPLOYMENT cluster."
    echo "  Cluster Name   : $CLUSTER_NAME"
    echo "  Cluster Region : $CLUSTER_REGION"
    echo ""
    echo "This will take several minutes"
    echo "===================================================="
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
    echo ""
    START_TIME=$(date)
    eksctl delete cluster --name=$CLUSTER_NAME --region=$CLUSTER_REGION
    ;;
  aks)
    AKS_RESOURCEGROUP="$RESOURCE_PREFIX-keptn-workshop-group"
    AKS_SERVICE_PRINCIPAL="$RESOURCE_PREFIX-keptn-workshop-sp"

    echo "===================================================="
    echo "About to delete $DEPLOYMENT_NAME cluster:"
    echo "  CLUSTER_NAME           : $CLUSTER_NAME"
    echo "  AKS_RESOURCEGROUP      : $AKS_RESOURCEGROUP"
    echo "  AKS_SERVICE_PRINCIPAL  : $AKS_SERVICE_PRINCIPAL"
    echo ""
    echo "This will take several minutes"
    echo "===================================================="
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
    echo ""
    START_TIME=$(date)

    echo "Deleting cluster $CLUSTER_NAME ..."
    az aks delete --name $CLUSTER_NAME --resource-group $AKS_RESOURCEGROUP
    echo "Deleting resource group $AKS_RESOURCEGROUP ..."
    az group delete --name $AKS_RESOURCEGROUP -y
    # need to look up service principal id and then delete it
    # this is outside of the resource group
    AKS_SERVICE_PRINCIPAL_APPID=$(az ad sp list --display-name $AKS_SERVICE_PRINCIPAL | jq -r '.[0].appId')
    if [ "$AKS_SERVICE_PRINCIPAL_APPID" != "null" ] ; then
      echo "Deleting service principal $AKS_SERVICE_PRINCIPAL ..."
      az ad sp delete --id $AKS_SERVICE_PRINCIPAL_APPID
    fi
    ;;
  gke)
    CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
    CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')
    GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

    echo "===================================================="
    echo "About to delete $DEPLOYMENT cluster."
    echo "  Project        : $GKE_PROJECT"
    echo "  Cluster Name   : $CLUSTER_NAME"
    echo "  Cluster Zone   : $CLUSTER_ZONE"
    echo ""
    echo "This will take several minutes"    
    echo "===================================================="
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
    echo ""
    START_TIME=$(date)
    # this command will prompt for confirmation
    gcloud container clusters delete $CLUSTER_NAME --zone=$CLUSTER_ZONE --project=$GKE_PROJECT 
    ;;
  *)
    echo "$DEPLOYMENT not supported"
    exit 1
    ;;
esac

echo "===================================================="
echo "Finished deleting $DEPLOYMENT Cluster"
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)
