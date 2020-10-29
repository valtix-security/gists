# Valtix Google Cloud Onboarding script
This script is provided by Valtix to create the two GCP Project service accounts needed to:

 1. allow Valtix controller access to deploy services into the GCP Project
 2. allow Valtix gateway access to GCP Secret Manager (optional)

 Pre-requisites: enable google APIs

 required: gcloud services enable compute.googleapis.com
 (optional): gcloud services enable secretmanager.googleapis.com

change this prefix variable to change the controller and gateway name prefix 
prefix=valtix
