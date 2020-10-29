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
# Begin Script

Write-Host "Setting up Valtix Controller Application registration & Service Principal.."

$AppID=az ad app create --display-name 'ValtixApp' --available-to-other-tenants true --query 'appId' -o tsv
$SPID=az ad sp create --id $AppID --query 'objectId' --output tsv
$Secret=az ad app credential reset --id $AppID --append --credential-description 'client-secret' --query 'password' -o tsv

# Get Subscription & Directory (Tenant) IDs
$SubscriptionID=(Get-AzContext).Subscription.id
$DirectoryID=(Get-AzContext).Tenant.Id

Write-Host "Creating custom role definition.."
$role = Get-AzRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = "valtix-controller-role"
$role.Description = "this role allows valtix-controller to deploy resources into the subscription"
$role.Actions.Clear()
$role.Actions.Add("Microsoft.Compute/virtualMachines/*")
$role.Actions.Add("Microsoft.Compute/disks/*")
$role.Actions.Add("Microsoft.Network/loadBalancers/*")
$role.Actions.Add("Microsoft.Network/publicIPAddresses/*")
$role.Actions.Add("Microsoft.Network/virtualNetworks/*")
$role.Actions.Add("Microsoft.Network/virtualNetworks/subnets/*")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourcegroups/*")
$role.Actions.Add("Microsoft.Network/networkSecurityGroups/*")
$role.Actions.Add("Microsoft.Storage/storageAccounts/blobServices/*")
$role.Actions.Add("Microsoft.Compute/images/read")
$role.Actions.Add("Microsoft.ApiManagement/service/*")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/$SubscriptionID")

# create the custom role
Write-Host "Creating custom role in IAM.."
$RoleName=New-AzRoleDefinition -Role $role | select -expand Name

# role assignment to app
Write-Host "Assigning custom role to App Service Principal.."
New-AzRoleAssignment -ObjectId $SPID -RoleDefinitionName $RoleName | Out-Null

#Accept Marketplace Terms
Write-Host "Accepting Marketplace Terms.."
az vm image terms accept --publisher valtix --offer datapath --plan valtix_dp_image --subscription $SubscriptionID -o none

# Output
Write-Host "-----------------------------------------------------------------"
Write-Host "Completed role setup"
Write-Host "Directory ID:" $DirectoryID
Write-Host "Subscription ID:" $SubscriptionID
Write-Host "Application ID:" $AppID
Write-Host "Client Secret:" $Secret
Write-Host "-----------------------------------------------------------------"

