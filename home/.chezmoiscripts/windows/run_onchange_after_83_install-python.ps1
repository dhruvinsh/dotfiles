# vim: set ft=powershell

pwsh -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

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
    "vectorcode[lsp,mcp]"
)

foreach ($package in $packages) {
  Write-Output "--> Installing $package.."
  uv tool install $package
}
