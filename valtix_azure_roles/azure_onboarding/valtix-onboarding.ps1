Invoke-WebRequest -Uri https://raw.githubusercontent.com/valtix-security/gists/main/valtix_azure_roles/valtix-controller-role.ps1 -OutFile test-onboarding.ps1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/valtix-security/gists/main/valtix_azure_roles/role.json -OutFile role.json

Get-Location
ls

echo "Getting the onboarding file"
