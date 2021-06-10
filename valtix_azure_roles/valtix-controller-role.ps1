# This Powershell script will register a Valtix Controller application and service principal assigned 
# with custom role to allow Valtix controller to deploy Valtix gateways into the Azure subscription 
#
# Pre-requisites:
# - current Azure portal user must have Azure AD access to register application and create custom roles and perform role assignment in current subscription
#
# Instructions: 
# - Open Azure Cloud Shell in the subscription you wish to register as account in Valtix
# - run script ./valtix-controller-role.ps1
#
# Parameters
$AppName = "ValtixApp"
$CustomRoleName = "valtix-controller-role"
$SecretKeyName = "client-secret"

# Begin Script
Write-Host "Setting up Valtix Controller Application registration & Service Principal.."

# Get Subscription & Directory (Tenant) IDs
$SubscriptionObj=(Get-AzContext).Subscription
$DirectoryObj=(Get-AzContext).Tenant

# Check to see if this is the correct subscription
Write-Host ""
Write-Host "-----------------------------------------------------------------"
Write-Host "Subscription Name:" $SubscriptionObj.Name
Write-Host "Subscription ID:" $SubscriptionObj.id
Write-Host "Directory ID:" $DirectoryObj.id
Write-Host "-----------------------------------------------------------------"
Write-Host ""
$confirmation = Read-Host "Valtix AzureAD App Registration will be made to this Directory and Subscription.  Would you like to continue? [y/n]"
while($confirmation -ne "y")
{
    if ($confirmation -eq 'n') 
    {
        Write-Host ""
        Write-Host "If this is the incorrect Subscription, use the following cmdlet to change it in Azure Cloud Shell:"
        Write-Host "Set-AzContext -Tenant <tenant id>"
        Write-Host ""
        exit
    }
    $confirmation = Read-Host "Ready? [y/n]"
}

# this is a workaround for Connect-AzureAD not working in PS1
# more info here: https://github.com/Azure/CloudShell/issues/72
import-module AzureAD.Standard.Preview
AzureAD.Standard.Preview\Connect-AzureAD -Identity -TenantID $DirectoryObj.id|Out-Null        

$AppObj=New-AzureADApplication -DisplayName $AppName -AvailableToOtherTenants 1
$SPObj=New-AzADServicePrincipal -DisplayName ServicePrincipalName -ApplicationId $AppObj.AppId -SkipAssignment
$SecretObj=New-AzureADApplicationPasswordCredential -ObjectId $AppObj.ObjectId -CustomKeyIdentifier $SecretKeyName

Write-Host ""
Write-Host "Creating custom role definition.."
$role = Get-AzRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = $CustomRoleName
$role.Description = "this role allows valtix-controller to deploy resources into the subscription"
$role.Actions.Clear()
$role.Actions.Add("Microsoft.ApiManagement/service/*")
$role.Actions.Add("Microsoft.Compute/disks/*")
$role.Actions.Add("Microsoft.Compute/images/read")
$role.Actions.Add("Microsoft.Compute/sshPublicKeys/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/*")
$role.Actions.Add("Microsoft.ManagedIdentity/userAssignedIdentities/read")
$role.Actions.Add("Microsoft.ManagedIdentity/userAssignedIdentities/assign/action")
$role.Actions.Add("Microsoft.Network/loadBalancers/*")
$role.Actions.Add("Microsoft.Network/networkinterfaces/*")
$role.Actions.Add("Microsoft.Network/networkSecurityGroups/*")
$role.Actions.Add("Microsoft.Network/publicIPAddresses/*")
$role.Actions.Add("Microsoft.Network/routeTables/*")
$role.Actions.Add("Microsoft.Network/virtualNetworks/*")
$role.Actions.Add("Microsoft.Network/virtualNetworks/subnets/*")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourcegroups/*")
$role.Actions.Add("Microsoft.Storage/storageAccounts/blobServices/*")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/" + $SubscriptionObj.id)

# create the custom role
Write-Host "Creating custom role in IAM.."
$CustomRoleObj=New-AzRoleDefinition -Role $role

# role assignment to app
Write-Host "Assigning custom role to App Service Principal.."
New-AzRoleAssignment -ObjectId $SPObj.Id -RoleDefinitionName $CustomRoleObj.Name | Out-Null

#Accept Marketplace Terms
Write-Host "Accepting Marketplace Terms.."
az vm image terms accept --publisher valtix --offer datapath --plan valtix_dp_image --subscription $SubscriptionObj.id -o none

# Output
Write-Host "-----------------------------------------------------------------"
Write-Host "Completed role setup"
Write-Host "Directory ID:" $DirectoryObj.id
Write-Host "Subscription ID:" $SubscriptionObj.id
Write-Host "Application ID:" $AppObj.AppId
Write-Host "Client Secret:" $SecretObj.value
Write-Host "-----------------------------------------------------------------"

