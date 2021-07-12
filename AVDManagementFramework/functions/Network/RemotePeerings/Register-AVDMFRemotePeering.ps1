function Register-AVDMFRemotePeering {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $RemoteVNetResourceID,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $LocalVNetResourceId
    )
    process {

        $remoteVNet = Get-AVDMFResourceInfo -ResourceId $RemoteVNetResourceID
        $localVNet = Get-AVDMFResourceInfo -ResourceId $LocalVNetResourceId

        $referenceName = "Peering_{0}_To_{1}" -f $RemoteVNet.ResourceName, $LocalVNet.ResourceName #this is used for the hashtable.
        $name = "Peering_To_{0}" -f $LocalVNet.ResourceName


        $script:RemotePeerings[$referenceName] = [PSCustomObject]@{
            PSTypeName          = 'AVDMF.Network.RemotePeering'
            Name                = $name
            SubscriptionId      = $remoteVNet.SubscriptionId #TODO: Implement Remote Subscription Support.
            ResourceGroupName   = $remoteVNet.ResourceGroupName
            RemoteVNetName      = $remoteVNet.ResourceName
            LocalVNetResourceId = $LocalVNetResourceId
        }
    }

}