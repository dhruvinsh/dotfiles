# vim: set ft=powershell

pwsh -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

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
