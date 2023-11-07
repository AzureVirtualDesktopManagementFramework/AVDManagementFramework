$websiteList = Import-Csv -Path "C:\GitDevOps\OQ\AVD-1\AVDMFConfiguration\HelperScripts\WebsiteRemoteAppTemplates\NewLinks.csv" -Delimiter "`t"

$remoteAppGroups = foreach($item in $websiteList){
    $referenceName = $item.ApplicationName -replace " ", "" -replace "\\",""
    $groupNamePrefix = "AVD-%StageNameAbv%-RemoteApp01-AG-"
    $groupName = "$groupNamePrefix{0}" -f $referenceName
    [ordered]@{
        Name = $referenceName
        RemoteAppReference = @($referenceName)
        Users = @($groupName)
    }

}
$remoteAppGroups | ConvertTo-Json |Set-Clipboard
