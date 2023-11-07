$websiteList = Import-Csv -Path "C:\GitDevOps\OQ\AVD-1\AVDMFConfiguration\HelperScripts\WebsiteRemoteAppTemplates\NewLinks.csv" -Delimiter "`t"


$templateArray = foreach($item in $websiteList){
    $remoteAppProperties = @{
        applicationType = "Inbuilt"
        friendlyName= $item.ApplicationName
        description= ""
        filePath= "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
        iconPath= "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
        iconIndex= 0
        commandLineSetting= "Require"
        commandLineArguments= "--app=$($item.URL)"
        showInPortal= $true
    }
    @{
        ReferenceName = $item.ApplicationName -replace " ", "" -replace "\\",""
        name          = $item.ApplicationName
        properties = $remoteAppProperties
    }
}
$templateArray | ConvertTo-Json |Set-Clipboard
