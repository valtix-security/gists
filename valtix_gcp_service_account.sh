#!/bin/bash
# This script is provided by Valtix to create the two GCP Project service accounts needed to:
#
# 1. allow Valtix controller access to deploy services into the GCP Project
# 2. allow Valtix gateway access to GCP Secret Manager (optional)
#
# Pre-requisites: enable google APIs
#
# required: gcloud services enable compute.googleapis.com
# (optional): gcloud services enable secretmanager.googleapis.com
#
# change this prefix variable to change the controller and gateway name prefix 
prefix=valtix
####################################################################################

# defining project id and service account names
project_id=$(gcloud config list --format 'value(core.project)')
sa_controller_name=${prefix}-controller
sa_gateway_name=${prefix}-gateway
printf 'Setting up service accounts in project: %s\n' $project_id
printf 'Valtix controller service account: %s\n' $sa_controller_name
printf 'Valtix gateway service account: %s\n' $sa_gateway_name

# wait for confirmation
read -p "Are you sure you want to go ahead? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
printf "Creating service accounts..\n"
gcloud iam service-accounts create $sa_controller_name \
    --description="service account used by Valtix to create resources in the project" \
    --display-name=$sa_controller_name \
    --no-user-output-enabled --quiet

gcloud iam service-accounts create $sa_gateway_name \
    --description="service account used by Valtix gateway to access GCP Secrets" \
    --display-name=$sa_gateway_name \
    --no-user-output-enabled --quiet

# wait for the service accounts to be created
while true; do
    printf "Wait until service accounts are created..\n"
    controller_result=$(gcloud iam service-accounts list --format=json --filter=name:$sa_controller_name | jq -r .[0].email)
    gateway_result=$(gcloud iam service-accounts list --format=json --filter=name:$sa_gateway_name | jq -r .[0].email)
    if [ "$controller_result" == "null" ] || [ "$gateway_result" == "null" ]; then
        sleep 5
    else
        break
    fi
done
sa_valtix_controller_email=$controller_result
sa_valtix_gateway_email=$gateway_result

printf 'Created valtix controller service account: %s\n' $sa_valtix_controller_email
printf 'Created valtix gateway service account: %s\n' $sa_valtix_gateway_email
printf "Binding IAM roles to service accounts..\n"
gcloud projects add-iam-policy-binding $project_id --member \
 serviceAccount:$sa_valtix_controller_email \
 --role "roles/compute.admin" \
 --no-user-output-enabled --quiet

gcloud projects add-iam-policy-binding $project_id --member \
 serviceAccount:$sa_valtix_controller_email \
 --role "roles/iam.serviceAccountUser" \
 --no-user-output-enabled --quiet

# This step is optional.  This is to allow Valtix Gateway service account access secrets from Secret Manager
gcloud projects add-iam-policy-binding $project_id --member \
 serviceAccount:$sa_valtix_gateway_email \
 --role "roles/secretmanager.secretAccessor" \
 --no-user-output-enabled --quiet

printf "Downloading JSON key to %s_key.json..\n" $prefix
gcloud iam service-accounts keys create ~/${prefix}_key.json \
  --iam-account $sa_valtix_controller_email
