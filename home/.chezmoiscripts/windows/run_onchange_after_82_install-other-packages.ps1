# vim: set ft=powershell

# lets make sure scoop have extra added (even after the initialization added for safety
# reason)
scoop bucket add extras

$apps = @(
    "fd"
    "fzf"
    "gcc"
    "lazygit"
    "ripgrep"
);

foreach ($app in $apps) {
    Write-Output "--> Installing $app.."
    scoop install $app
}