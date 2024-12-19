$Env:Path = "$Env:USERPROFILE\.local\bin;$env:Path"
$Env:NVIM_COLORSCHEME = "catppuccin"

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

# adding auto-completion support for uv
(& uv generate-shell-completion powershell) | Out-String | Invoke-Expression
(& uvx --generate-shell-completion powershell) | Out-String | Invoke-Expression
