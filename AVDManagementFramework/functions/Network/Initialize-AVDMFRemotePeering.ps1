function Initialize-AVDMFRemotePeering {
    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable')]

    $templateParams = @{
        RemotePeerings = [array] ($script:RemotePeerings | Convert-HashtableToArray)
    }
    $templateParams

}