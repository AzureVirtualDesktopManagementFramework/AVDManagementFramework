function Get-AVDMFResourceInfo {
    [CmdletBinding()]
    param (
        [string] $ResourceId
    )
    $pattern = '^\/subscriptions\/(?<SubscriptionId>.+)\/resourceGroups\/(?<ResourceGroupName>.+)\/providers.+\/(?<ResourceName>.+$)'
    if($ResourceId -match $pattern){
        [PSCustomObject]@{
            SubscriptionId = $Matches.SubscriptionId
            ResourceGroupName = $Matches.ResourceGroupName
            ResourceName = $Matches.ResourceName
        }
    }
    else {throw "Resource ID is not valid: $ResourceId"}
}