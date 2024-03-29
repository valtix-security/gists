# Parameters
$AppName = "michael-ValtixApp"
$CustomRoleName = "michael-valtix-controller-role"
$SecretKeyName = "michae-client-secret"

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
#$confirmation = Read-Host "Valtix AzureAD App Registration will be made to this Directory and Subscription.  Would you like to continue? [y/n]"
#while($confirmation -ne "y")
#{
#    if ($confirmation -eq 'n') 
#    {
#        Write-Host ""
#        Write-Host "If this is the incorrect Subscription, use the following cmdlet to change it in Azure Cloud Shell:"
#        Write-Host "Set-AzContext -Tenant <tenant id>"
#        Write-Host ""
#        exit
#    }
#    $confirmation = Read-Host "Ready? [y/n]"
#}

# this is a workaround for Connect-AzureAD not working in PS1
# more info here: https://github.com/Azure/CloudShell/issues/72
Install-Module AzureAD.Standard.Preview
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
$role.Actions.Add("Microsoft.Network/locations/serviceTags/read")
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
#az vm image terms accept --publisher valtix --offer datapath --plan valtix_dp_image --subscription $SubscriptionObj.id -o none

Get-AzMarketplaceTerms -Publisher "valtix" -Product "valtix-cloud-security" -Name "val_bnd3_b8_azure" | Set-AzMarketplaceTerms -Accept

# Output
Write-Host "-----------------------------------------------------------------"
Write-Host "Completed role setup"
Write-Host "Directory ID:" $DirectoryObj.id
Write-Host "Subscription ID:" $SubscriptionObj.id
Write-Host "Application ID:" $AppObj.AppId
Write-Host "Client Secret:" $SecretObj.value
Write-Host "-----------------------------------------------------------------"
