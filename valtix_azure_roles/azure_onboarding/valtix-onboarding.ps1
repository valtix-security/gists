Invoke-WebRequest -Uri https://raw.githubusercontent.com/valtix-security/gists/main/valtix_azure_roles/azure_onboarding/role.json -OutFile role.json

APP_NAME="michael-valtix-controller-app"
ROLE_NAME="michael-valtix-controller-role"

account_info=$(az account show)
sub_id=$(echo $account_info | jq -r .id)
tenant_id=$(echo $account_info | jq -r .tenantId)

app_output=$(az ad app create --display-name $APP_NAME)
app_output=$(az ad app list --display-name $APP_NAME)
echo "app_output: $app_output"
app_id=$(echo $app_output | jq -r .appId)
sp_object_id=$(az ad sp create --id $app_id | jq -r .objectId)
secret=$(az ad app credential reset --id $app_id --credential-description 'valtix-secret' --years 5 2>/dev/null | jq -r .password)

sed -e "s/ROLENAME/$ROLE_NAME/" -e "s/SUBSCRIPTION/$sub_id/g" role.json > /tmp/role.json

az role definition create --role-definition /tmp/role.json &> /dev/null
az role assignment create --assignee-object-id $sp_object_id --assignee-principal-type ServicePrincipal --role $ROLE_NAME &> /dev/null

echo "AccountInfo: $account_info\r"
echo "Tenant/Directory: $tenant_id\r"
echo "Subscription: $sub_id\r"
echo "App: $app_id\r"
echo "Secret: $secret\r"

echo "az role assignment delete --assignee $sp_object_id --role $ROLE_NAME" > delete-azure-setup.sh
echo "az role definition delete --name $ROLE_NAME" >> delete-azure-setup.sh
echo "az ad app delete --id $app_id" >> delete-azure-setup.sh
echo "rm delete-azure-setup.sh" >> delete-azure-setup.sh

