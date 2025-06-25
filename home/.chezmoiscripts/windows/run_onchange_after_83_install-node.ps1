# vim: set ft=powershell

# lets make sure scoop have volta installed
scoop install "main/volta"

$vpackages = @(
    "node@lts"
    "pnpm"
    "vite"
    "yarn"
);

foreach ($vpackage in $vpackages) {
    Write-Output "--> Installing $vpackage.."
    volta install $vpackage
}

# update npm to latest version
npm install -g npm

Write-Output "Some node application installation for development"
$applications = @(
  "neovim"
  "prettier"
  "tree-sitter-cli"
  "@google/gemini-cli"
  "@openai/codex"
  "opencode-ai@latest"
)
foreach ($application in $applications) {
    Write-Output "--> Installing $application globally.."
    npm install -g $application
}
