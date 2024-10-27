# vim: set ft=powershell:

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
scoop bucket add versions

# NOTE: do not install 7zip from scoop else we will have issue
# for file extraction for scoop
$apps = @(
    "extras/lazygit"
    "extras/putty"
    "extras/selene"
    "extras/sublime-merge"
    "extras/sublime-text"
    "extras/vcredist2022" # ripgrep needs it
    "extras/wezterm"
    "main/ast-grep"
    "main/bat"
    "main/chafa"
    "main/cmake"
    "main/delta"
    "main/fd"
    "main/fzf"
    "main/gcc"
    "main/git"
    "main/git-cliff"
    "main/glow"
    "main/just"
    "main/luarocks"
    "main/make"
    "main/neovim"
    "main/nu"
    "main/ripgrep"
    "main/sed"
    "main/yazi"
    "main/yq"
    "main/zoxide"
);



foreach ($app in $apps) {
    Write-Output "--> Installing $app.."
    scoop install $app
}
