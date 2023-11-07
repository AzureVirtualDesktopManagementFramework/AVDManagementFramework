function Convert-MDTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true ,ValueFromPipeline = $true )]
        [string] $MDTable
    )

    $table = $MDTable -split "`n" #Separate each line
    $table = $table | ForEach-Object {$_ -Replace("\s\s","") -Replace("^\|\s","") -Replace("\s\|$","") -Replace("\s|\s","") -replace "\*",""}
    $table = @($table[0]) + $table[2..($table.Count-1)] #Remove --- line
    $table = $table | ConvertFrom-Csv -Delimiter "|" -WarningAction 'SilentlyContinue'
    $table = $table | ConvertTo-Json

    return $table
}