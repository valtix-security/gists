Invoke-WebRequest -Uri https://raw.githubusercontent.com/valtix-security/gists/main/valtix_azure_roles/valtix-controller-role.ps1 -OutFile test-onboarding.ps1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/valtix-security/gists/main/valtix_azure_roles/azure_onboarding/role.json -OutFile role.json

$output = Get-Location
$output1 = ls

echo "Getting the onboarding file"
echo $output
echo $output1
echo "Complete"
Write-Output $output
Write-Output $output1
