# vim: set ft=powershell

# lets make sure scoop have nerd-fonts added
scoop bucket add nerd-fonts

# NOTE: do not install 7zip from scoop else we will have issue
# for file extraction for scoop
$fonts = @(
  "nerd-fonts/Cascadia-Code"
  "nerd-fonts/FiraCode-NF"
  "nerd-fonts/Iosevka-NF"
  "nerd-fonts/JetBrainsMono-NF"
  "nerd-fonts/Maple-Mono-NF"
  "nerd-fonts/VictorMono-NF"
);


foreach ($font in $fonts) {
    Write-Output "--> Installing $font.."
    scoop install $font
}
