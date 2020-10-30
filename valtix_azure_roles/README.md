# Valtix Azure Onboarding script
This Powershell script will register a Valtix Controller application and service principal assigned 
with custom role to allow Valtix controller to deploy Valtix gateways into the Azure subscription 

### Pre-requisites
Current Azure portal user must have Azure AD access to register application and create custom roles and perform role assignment in current subscription

## How to use:

Open Azure Cloud Shell (Powershell) in the subscription you wish to register as account in Valtix

Download the PowerShell script and run
```
wget https://raw.githubusercontent.com/valtix-security/gists/main/valtix_azure_roles/valtix-controller-role.ps1
./valtix-controller-role.ps1
```


