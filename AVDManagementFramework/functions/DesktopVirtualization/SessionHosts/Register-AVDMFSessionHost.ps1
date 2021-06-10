function Register-AVDMFSessionHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $AccessLevel,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolType,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolInstance,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [int] $InstanceNumber,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [object] $VMTemplate,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [object] $SubnetID,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $DomainName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $OUPath

    )
    process {
        $ResourceName = New-AVDMFResourceName -ResourceType 'VirtualMachine' -AccessLevel $AccessLevel -HostPoolType $HostPoolType -HostPoolInstance $HostPoolInstance -InstanceNumber $InstanceNumber

        $script:SessionHosts[$resourceName] = [PSCustomObject]@{
            ResourceGroupName = $ResourceGroupName
            VMSize            = $VMTemplate.VMSize
            TimeZone          = $script:TimeZone
            SubnetID          = $SubnetID
            AdminUsername     = $VMTemplate.AdminUserName
            AdminPassword     = $VMTemplate.AdminPassword
            ImageReference    = $VMTemplate.ImageReference

            # Add Session Host
            WVDArtifactsURL   = $VMTemplate.WVDArtifactsURL

            # Domain Join
            DomainName = $DomainName
            OUPath = $OUPath
            DomainJoinUserName = $script:DomainJoinUserName
            DomainJoinPassword = $script:DomainJoinPassword
        }
    }
}