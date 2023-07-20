# zoxide
if (Get-Command zoxide -errorAction SilentlyContinue)
{
  Set-Alias z zoxide
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
