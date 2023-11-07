Write-Output "Validating Bicep Files"

az bicep list-versions
az bicep build --file 'MyFirstTemplate\NewVMBicep.bicep'

Write-Output "Validating PowerShell Files"
.\Tests\ValidateAllPSFiles.ps1