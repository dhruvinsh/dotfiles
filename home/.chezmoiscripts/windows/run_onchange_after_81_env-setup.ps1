# modify the env value per user

Write-Output "--> Setting ComSpec variable to pwsh 7"
try {
    if (Get-Command pwsh) {
        $PWSH = (Get-Command pwsh).Path
        [Environment]::SetEnvironmentVariable("ComSpec", $PWSH, "User")
    }
}
catch {
    Write-Output "Can not able to set ComSpec variable"   
}