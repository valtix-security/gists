# Valtix Azure Onboarding script

This Powershell script will register a Valtix Controller application and service principal assigned 
with custom role to allow Valtix controller to deploy Valtix gateways into the Azure subscription 

Pre-requisites:
 - current Azure portal user must have Azure AD access to register application and create custom roles and perform role assignment in current subscription

 Instructions: 
 - Open Azure Cloud Shell in the subscription you wish to register as account in Valtix
 - run script ./valtix-controller-role.ps1

<b>valtix-controller-role.ps1</b> - run this script in Azure Cloud Shell to deploy Azure App Registration and custom role to add Azure CSP 

