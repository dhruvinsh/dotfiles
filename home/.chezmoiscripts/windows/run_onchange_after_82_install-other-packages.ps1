# vim: set ft=powershell

# NOTE: for future, https://github.com/ScoopInstaller/Extras/issues/1861#issuecomment-1320653215
# You can install Visual Studio Build Tools using:
# ```
# Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_BuildTools.exe' -OutFile "$env:TEMP\vs_BuildTools.exe"
# & "$env:TEMP\vs_BuildTools.exe" --passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --remove Microsoft.VisualStudio.Component.VC.CMake.Project	
# ```
# Don't include --remove Microsoft.VisualStudio.Component.VC.CMake.Project if you want CMake to be included. Personally, I use scoop install cmake as that has a newer version.

# lets make sure scoop have extra added (even after the initialization added for safety
# reason)
scoop bucket add extras

$apps = @(
    "cmake"
    "fd"
    "fzf"
    "gcc"
    "lazygit"
    "make"
    "ripgrep"
    "vcredist2022" # ripgrep needs it
);

foreach ($app in $apps) {
    Write-Output "--> Installing $app.."
    scoop install $app
}