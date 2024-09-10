# vim: set ft=powershell

# lets make sure scoop have volta installed
scoop install "main/volta"

$vpackages=@(
    node
    pnpm
    vite
    yarn
);

foreach ($vpackage in $vpackages) {
    Write-Output "--> Installing $vpackage.."
    volta install $vpackage
}
