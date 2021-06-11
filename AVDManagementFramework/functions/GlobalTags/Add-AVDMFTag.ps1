function Add-AVDMFTag {
    <#
    .SYNOPSIS
        Adds tags to resources
    #>
    [CmdletBinding()]
    param (
        # ResourceType
        [Parameter(Mandatory = $true)]
        [string] $ResourceType,

        # Resource Object
        [Parameter(Mandatory = $true)]
        $ResourceObject
    )
    # Tags that apply to all resources
    if($script:GlobalTags['All']){
        $effectiveTags = $script:GlobalTags['All'].Clone()
    }

    # Tags that apply to all instaces of a specific resource type
    if($script:GlobalTags[$ResourceType]){
        $resourceTypeTags = $script:GlobalTags[$ResourceType]
        foreach($item in $resourceTypeTags.GetEnumerator()) {$effectiveTags[$item.Key] = $item.Value}
    }

    if($ResourceObject.Tags){
        $resourceSpecificTags = $ResourceObject.Tags | ConvertTo-PSFHashtable
        foreach($item in $resourceSpecificTags.GetEnumerator()) {$effectiveTags[$item.Key] = $item.Value}
    }



    if ($effectiveTags) {
        $ResourceObject | Add-Member -MemberType NoteProperty -Name Tags -Value $effectiveTags -Force
    }

    $ResourceObject
}