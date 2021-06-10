function Register-AVDMFGlobalSettings {
    param (
        # Stage
        [string]
        $Stage
    )
    $script:AVDMFGlobalSettings = [PSCustomObject]@{
        Stage = $Stage
    }
}