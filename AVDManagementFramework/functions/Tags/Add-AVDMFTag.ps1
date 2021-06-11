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
        $ResourceObject,

        # Tags to attach to this specific resource
        [Parameter(Mandatory = $false)]
        [Hashtable]$ResourceSpecificTags #This is not yet developed
    )

    $genericTags = $Script:Tags[$ResourceType]

    if ($genericTags) {
        $ResourceObject | Add-Member -MemberType NoteProperty -Name Tags -Value $genericTags
    }

    $ResourceObject
}