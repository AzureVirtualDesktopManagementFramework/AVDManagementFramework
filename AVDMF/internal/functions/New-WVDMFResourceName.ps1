function New-WVDMFResourceName {
    <#
    .SYNOPSIS
        This function generates resource names as per the naming convention.
    .DESCRIPTION
        The function reads naming conventions and abbreviations from configuration files and outputs resource names to use.
    .EXAMPLE
        TODO: Add Examples
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = "Does not change any states")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $ResourceType,
        [string] $DeploymentStage = $script:DeploymentStage,
        [string] $ResourceCategory,
        [string] $AccessLevel, # Enterprise, Specialist, Privileged
        [string] $HostPoolType, # Shared, Dedicated

        [string] $HostPoolInstance,

        [string] $ParentName,
        [string] $AddressPrefix,


        [Int] $InstanceNumber

        #TODO: Change parameters to overloads so we don't have to provide them. (Except deployment stage?)
    )

    $namingStyle = $script:NamingStyles | Where-Object { $_.ResourceType -eq $ResourceType }
    if (-not $namingStyle) {
        $namingStyle = $script:NamingStyles | Where-Object { $_.ResourceType -eq 'Default' }
    }

    [array] $nameArray = foreach ($component in $namingStyle.NameComponents) {
        if ($component -like "*Abv") {
            $componentName = $component -replace "Abv", ""
            $componentNC = $component -replace "Abv", "NC"

            #Check if component naming convention is avaialbe
            # TODO: Use hashtable for naming conventions instead of dynamic variable names!
            # Assumption - hashtable stored in $script:namingConvention
            try { Get-Variable -Name $componentNC -ErrorAction Stop | Out-Null }
            catch { throw "Could not find a naming convention for component: $componentName. It should be supplied in configuration as .\NamingConvention\Components\$($componentName).json" }

            # Default or custom abbreviation
            $componentNCmembers = (get-variable -Name $componentNC).value | Get-Member -MemberType NoteProperty | Where-Object Name -NE $componentName
            $abbreviationMarker = ($componentNCmembers | Where-Object Name -EQ ("{0}Abv" -f $ResourceType)).Name
            if (-Not $abbreviationMarker) { $abbreviationMarker = "Abbreviation" }

            if ($componentName -eq 'Subscription') {

                $namingConvention = (Get-Variable -Name $componentNC -Scope Script).Value
                $filterScript = [ScriptBlock]::Create("`$_.DeploymentStage -eq `$DeploymentStage")
                #$Command = "(`$Script:$componentNC | Where-Object DeploymentStage -contains `$DeploymentStage).$abbreviationMarker" #TODO: Remove me
            }
            else {
                $namingConvention = (Get-Variable -Name $componentNC -Scope Script).Value
                $filterScript = [ScriptBlock]::Create("`$_.$componentName -eq `$$componentName")

                #$Command = "(`$Script:$componentNC | Where-Object $componentName -eq `$$componentName).$abbreviationMarker" #TODO: Remove me
                #TODO: Review with Fred

            }
            #FRED: $script:namingConvention[$componentName].$abbreviationMarker
            #$abv = Invoke-Expression -Command $Command #TODO:  Remove me
            $abv = ($namingConvention | Where-Object -FilterScript $filterScript).$abbreviationMarker
            if (-not $abv) {throw "Could not find any abbreviation for $componentName`: $((Get-Variable -Name $componentName).Value)" }
            $abv
        }
        if ($component -in ('-', '_')) { $component }

        if ($component -eq 'ParentName') {
            $ParentName
        }

        if ($component -eq 'AddressPrefix') {
            $AddressPrefix -replace "/", "-"
        }
        if ($component -eq 'HostPoolInstance') {
            $HostPoolInstance
        }
    }
    $resourceName = $nameArray -join "" -replace "-All", "" -replace "All", ""
    if ($namingStyle.LowerCase) { $resourceName = $resourceName.ToLower() }

    if ($namingStyle.NameComponents[-1] -eq 'InstanceNumber') {
        #TODO: Move this part to the main loop.
        if ($InstanceNumber) {
            $resourceName = "{0}{1:D2}" -f $resourceName, $InstanceNumber
        }
        else {
            $scriptResourceType = (Get-Variable -Name "$($ResourceType)s" -Scope Script).Value
            $filterScript = [ScriptBlock]::Create("`$_ -like `"$resourceName*`"")
            $count = ($scriptResourceType.Keys | Where-Object -FilterScript $filterScript).Count

            #TODO: Fix this once we have resource name attribute for all resource
            if($count -eq 0){
                $count = ($scriptResourceType.GetEnumerator() | ForEach-Object{$_.Value.ResourceName} | Where-Object -FilterScript $filterScript).count
            }

            $resourceName = "{0}{1:D2}" -f $resourceName, ($Count + 1)
        }
    }

    if ($resourceName.length -gt $namingStyle.MaxLength) { throw "resulting resource name is longer than $($namingStyle.MaxLength) characters '$resourceName'" }

    $resourceName
}
