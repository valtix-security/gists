# Valtix Google Cloud Onboarding script
This script is provided by Valtix to create the two GCP Project service accounts needed to:

 1. allow Valtix controller access to deploy services into the GCP Project
 2. allow Valtix gateway access to GCP Secret Manager (optional)

### Pre-requisites: enable google APIs

ensure that you have set the project context
```
gcloud config set project <project-id>
```

enable compute engine API and enable IAM API
```
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
```
*(optional): if you use Secrets Manager to store TLS certificates, enable secret manager API
```
gcloud services enable secretmanager.googleapis.com
```

change this prefix variable to change the controller and gateway name prefix 
prefix=valtix
