Describe "No-Breaking-Points" {
    Context "When there are breaking points in code" {
        It "Should not happen" {
            $path = '.\PowerShellModules\WVDManagementFramework'
            $psFiles = Get-ChildItem -Path $path -Filter '*.ps1' -Recurse
            $BreakingPoints = $psFiles | ForEach-Object -Parallel  {if(Get-Content -Path $_.FullName | Where-Object {$_ -like '*$bp*'}) {$_.FullName}}
            $BreakingPoints | should -be $null
        }
    }
}