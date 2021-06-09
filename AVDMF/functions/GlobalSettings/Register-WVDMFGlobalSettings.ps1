function Register-WVDMFGlobalSettings {
    param (
        # Stage
        [string]
        $Stage
    )
    $script:WVDMFGlobalSettings = [PSCustomObject]@{
        Stage = $Stage
    }
}