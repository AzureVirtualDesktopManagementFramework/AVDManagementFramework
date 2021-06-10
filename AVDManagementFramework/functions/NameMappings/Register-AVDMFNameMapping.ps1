function Register-AVDMFNameMapping {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $Name,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $VariableName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [Object] $Value


    )
    process {
        if($VariableName -like "$*"){
            throw "Variable names in Name Mapping cannot start with '$'"
        }
        $variableNameValue = if($VariableName -like "env:*"){
            (Get-Item -Path $VariableName).Value
        }
        else{
            (Get-Variable -Name $VariableName).Value
        }
        $script:NameMappings[$Name] = $Value.$variableNameValue
    }
}