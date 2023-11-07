# Get list of all PS1 files under root
Get-location | Format-Table
Get-ChildItem

$ScriptAnalyzer = Invoke-ScriptAnalyzer -Path .\PowerShellModules\WVDManagementFramework\1.0.0\functions -Recurse

if($ScriptAnalyzer) {
    write-output ($ScriptAnalyzer | Format-Table -AutoSize | Out-String -Width 250)
    throw 'Script Analyzer did not pass.'
}
$ScriptAnalyzer = Invoke-ScriptAnalyzer -Path .\PowerShellModules\WVDManagementFramework\1.0.0\internal -Recurse
if($ScriptAnalyzer) {
    write-output ($ScriptAnalyzer | Format-Table -AutoSize | Out-String -Width 250)
    throw 'Script Analyzer did not pass.'
}