# vim: set ft=powershell

$shimPath = "$env:USERPROFILE\AppData\Local\mise\shims"
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$newPath = $currentPath + ";" + $shimPath
[Environment]::SetEnvironmentVariable('Path', $newPath, 'User')

# create some independent envs with packages
$packages = @(
    "aider-chat"
    "codespell"
    "files-to-prompt"
    "httpie"
    "jupyterlab"
    "keymap-drawer"
    "llm"
    "mypy"
    "pipenv"
    "poetry"
    "pre-commit"
    "ruff"
    "streamdown"
)

foreach ($package in $packages) {
  Write-Output "--> Installing $package.."
  uv tool install --force $package
}
