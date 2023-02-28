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
        [ValidateSet("AAD", "ADDS")]
        [string] $SessionHostJoinType,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $DomainName,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $OUPath,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $AvailabilityZone = '',

        [PSCustomObject] $Tags = [PSCustomObject]@{}

    )
    process {

        $ResourceName = New-AVDMFResourceName -ResourceType 'VirtualMachine' -AccessLevel $AccessLevel -HostPoolType $HostPoolType -HostPoolInstance $HostPoolInstance -InstanceNumber $InstanceNumber

        $script:SessionHosts[$resourceName] = [PSCustomObject]@{ # TODO: Is it a good idea to switch this to hashtable not custom object?
            ResourceGroupName     = $ResourceGroupName
            VMSize                = $VMTemplate.VMSize
            TimeZone              = $script:TimeZone
            SubnetID              = $SubnetID
            AdminUsername         = $VMTemplate.AdminUserName
            AdminPassword         = $VMTemplate.AdminPassword
            ImageReference        = $VMTemplate.ImageReference
            AcceleratedNetworking = $VMTemplate.AcceleratedNetworking
            Tags                  = $Tags
            AvailabilityZone      = $AvailabilityZone
            PreJoinRunCommand     = $VMTemplate.PreJoinRunCommand

            # Add Session Host
            WVDArtifactsURL       = $VMTemplate.WVDArtifactsURL

            SessionHostJoinType   = $SessionHostJoinType
        }
        # AAD or Domain Join
        switch ($SessionHostJoinType) {
            "AAD" {

            }
            "ADDS" {
                $script:SessionHosts[$resourceName] | Add-Member -MemberType NoteProperty -Name DomainName -Value $DomainName
                $script:SessionHosts[$resourceName] | Add-Member -MemberType NoteProperty -Name OUPath -Value $OUPath
                $script:SessionHosts[$resourceName] | Add-Member -MemberType NoteProperty -Name DomainJoinUserName -Value $script:DomainJoinUserName
                $script:SessionHosts[$resourceName] | Add-Member -MemberType NoteProperty -Name DomainJoinPassword -Value $script:DomainJoinPassword
            }
        }
    }
}