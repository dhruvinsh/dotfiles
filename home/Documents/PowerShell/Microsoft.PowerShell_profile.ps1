# zoxide
if (Get-Command zoxide -errorAction SilentlyContinue)
{
  Set-Alias z zoxide
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Command volta -errorAction SilentlyContinue)
{
  (& volta completions powershell) | Out-String | Invoke-Expression
}
