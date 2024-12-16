# vim: set ft=powershell

pwsh -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# adding auto-completion support
Add-Content -Path $PROFILE -Value '(& uv generate-shell-completion powershell) | Out-String | Invoke-Expression'
Add-Content -Path $PROFILE -Value '(& uvx --generate-shell-completion powershell) | Out-String | Invoke-Expression'

# create some independent envs with packages
$packages = @(
    "black"
    "codespell"
    "flake8"
    "httpie"
    "isort"
    "jupyterlab"
    "mypy"
    "pipenv"
    "poetry"
    "pre-commit"
    "pylint"
    "ruff"
)

foreach ($package in $packages) {
  Write-Output "--> Installing $package.."
  uv tool install $package
}
