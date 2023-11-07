function Set-ResourceFolders {
    Param(
        # Resource Type
        [string]
        $ResourceType
    )

    $functionNames = @('Get','Register','Unregister') #@('Get','Invoke','Register','Test','Unregister')

    $path = ".\PowerShellModules\WVDManagementFramework\1.0.0\functions\DesktopVirtualization\$($ResourceType)s"
    New-Item -Path $path -ItemType Directory -Force | Out-Null
    foreach ($name in $functionNames){
        $FileName = "{0}-WVDMF{1}.ps1" -f $name,$ResourceType

        New-Item -Path $path -Name $FileName
    }

}