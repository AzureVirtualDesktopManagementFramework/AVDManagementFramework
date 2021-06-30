function Set-AVDMFStageEntries {
    <#
    .SYNOPSIS
        This function replaces "Stages" token in json objects depending on the current stage or a default one.
    .Example
        $json = @"
        {
            "SampleProperty": {
                "DeploymentStage": {
                    "Development": 10,
                    "Production": 5,
                    "Default": 15
                }
            }
        }
        "@
        $dataset = $json | ConvertFrom-Json | ConvertTo-PSFHashtable
        Set-AVDMFStageEntries -Dataset $dataset

        Assuming the current stage name is "Development", the output will be that SampleProperty = 10
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable] $Dataset,

        [string] $DeploymentStage = $script:DeploymentStage,
        [string] $StageToken = "DeploymentStage"
    )
    foreach ($key in ([array]$Dataset.Keys)) {

        if ($null -eq $Dataset[$key]) { continue }

        if ($Dataset[$key].GetType().Name -eq 'PSCustomObject') {
            if ($Dataset[$key] | Get-Member -MemberType NoteProperty -Name $StageToken) {
                # Get list of configured stages under the stage token
                $configuredStages = ($Dataset[$key].$StageToken | Get-Member -MemberType NoteProperty).Name

                if ( $configuredStages -contains $DeploymentStage) {
                    $Dataset[$key] = $Dataset[$key].$StageToken.($DeploymentStage)
                    Write-PSFMessage -Level Verbose -Message "Set $key to $DeploymentStage value: $($Dataset[$key])"
                }
                elseif ( $configuredStages -contains "Default" ) {
                    $Dataset[$key] = $Dataset[$key].$StageToken.Default
                    Write-PSFMessage -Level Verbose -Message "Set $key to Default value: $($Dataset[$key])"
                }
                else {
                    throw "Could not resolve stage value ($DeploymentStage) for `r`n $($Dataset | Out-String)"
                }
            }
            else { # key is a PSCustomObject that does not have a stage token, maybe one of its children.
                $Dataset[$key] = [PSCustomObject] (Set-AVDMFStageEntries -Dataset ($Dataset[$key] | ConvertTo-PSFHashtable))
            }
        }
    }
    $Dataset
}
