$websiteList = Import-Csv -Path "C:\temp\WebsiteList.csv" -Delimiter "`t"
$avdUsersGroup = "AVD Users"
$groups = ( # We will need one group per AG per Stage
    @{ # Development
        Prefix = "AVD-Dev-RemoteApp01-AG-"
        OUPath = "OU=ApplicationGroups,OU=RemoteApp01,OU=Development,OU=Development,OU=AVD,DC=orpic,DC=om"
    },
    @{ # Preview
        Prefix = "AVD-Prv-RemoteApp01-AG-"
        OUPath = "OU=ApplicationGroups,OU=RemoteApp01,OU=Preview,OU=Production,OU=AVD,DC=orpic,DC=om"
    },
    @{ # General Availability
        Stage = "GA"
        Prefix = "AVD-GA-RemoteApp01-AG-"
        OUPath = "OU=ApplicationGroups,OU=RemoteApp01,OU=GeneralAvailability,OU=Production,OU=AVD,DC=orpic,DC=om"
    }
)


$ErrorActionPreference = 'stop'

foreach ($item in $websiteList) {
    $referenceName = $item.ApplicationName -replace " ", "" -replace "\\", ""
    foreach($group in $groups){
        $groupName = "{0}{1}" -f $group.Prefix,$referenceName
        $null = New-ADGroup -Name $groupName -GroupCategory Security -GroupScope Global -Path $group.OUPath

        if($group.Stage -eq "GA"){
            $groupMembers = $item.Users -split "," | ForEach-Object { $_ -replace "ORPIC\\", "" }
            Add-ADGroupMember -Identity $avdUsersGroup -Members $groupName
            if ($groupMembers) {
                Add-ADGroupMember -Identity $groupName -Members $groupMembers
            }
        }
    }
}
