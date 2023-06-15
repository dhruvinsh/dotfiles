# vim: set ft=powershell:

# Credits: https://github.com/twpayne/dotfiles
# https://www.prajwaldesai.com/disable-search-highlights-on-windows-11/

New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force
New-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "EnableDynamicContentInWSB" -PropertyType DWORD -Value 0