# modify the env value per user

# NOTE: change in comspec create lot of issue, specially with NPM with memory leak
# Write-Output "--> Setting ComSpec variable to pwsh 7"
# try {
#     if (Get-Command pwsh) {
#         $PWSH = (Get-Command pwsh).Path
#         [Environment]::SetEnvironmentVariable("ComSpec", $PWSH, "User")
#     }
# }
# catch {
#     Write-Output "Can not able to set ComSpec variable"   
# }