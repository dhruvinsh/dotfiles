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

# mise shims: persist to the User PATH once (only affects new processes), and
# prepend to this session's PATH so mise-managed tools like starship resolve now
$shimPath = "$env:USERPROFILE\AppData\Local\mise\shims"
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($currentPath -notlike "*$shimPath*")
{
  [Environment]::SetEnvironmentVariable('Path', "$currentPath;$shimPath", 'User')
}
if ($Env:Path -notlike "*$shimPath*")
{
  $Env:Path = "$shimPath;$Env:Path"
}

# starship config (installed via mise)
if (Get-Command starship -errorAction SilentlyContinue)
{
  $ENV:STARSHIP_CACHE = "$HOME\AppData\Local\Temp"
  $ENV:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
  Invoke-Expression (&starship init powershell)
}
