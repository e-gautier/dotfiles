#Requires -RunAsAdministrator

# enable firewall with default block
Set-NetFirewallProfile -All -Enabled True
Set-NetFirewallProfile -All -DefaultInboundAction Block -DefaultOutboundAction Allow -NotifyOnListen True -AllowUnicastResponseToMulticast True -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log

# remove all existing rules
Remove-NetFirewallRule -All

# install binaries
Set-Variable -Name "BINARY_INSTALL" -Value 'Get-Content "$HOME\dotfiles\windows\binaries" | ForEach-Object{($_ -split "\r\n")[0]} | ForEach-Object{winget install -y --accept-license $_}'
$CHOICE = Read-Host "Install binaries ([Y]/n)? "
switch ($CHOICE) {
  { 'n', 'N' -contains $_ } { break }
  Default { Invoke-Expression $BINARY_INSTALL; break }
}

# symlinks
# VSCodium
New-Item -Force -Path $HOME\AppData\Roaming\VSCodium\User\settings.json -ItemType SymbolicLink -Value $HOME\dotfiles\vscodium\settings.json
New-Item -Force -Path $HOME\AppData\Roaming\VSCodium\User\keybindings.json -ItemType SymbolicLink -Value $HOME\dotfiles\vscodium\keybindings.json
# Powershell profile
New-Item -Force -Path $HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -ItemType SymbolicLink -Value $HOME\dotfiles\windows\Microsoft.PowerShell_profile.ps1
# Microsoft terminal
New-Item -Force -Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json -ItemType SymbolicLink -Value $HOME\dotfiles\windows\microsoft_terminal\settings.json

# install vscode extensions
Set-Variable -Name "VSCODE_EXTENSIONS_INSTALL" -Value 'Get-Content $HOME\dotfiles\vscode\extensions | ForEach-Object{($_ -split "\r\n")[0]} | ForEach-Object{codium --install-extension $_}'
$CHOICE = Read-Host "Install VScode extensions ([Y]/n)? "
switch ($CHOICE) {
  { 'y', 'Y' -contains $_ } { Invoke-Expression $VSCODE_EXTENSIONS_INSTALL; break }
  { 'n', 'N' -contains $_ } { }
  Default { Invoke-Expression $VSCODE_EXTENSIONS_INSTALL; break }
}

# set run at startup registries
# for userland execution:
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SyncTrayzor" -Value """$env:ProgramFiles\SyncTrayzor\SyncTrayzor.exe"" -minimized"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "CopyQ" -Value "${env:ProgramFiles(x86)}\CopyQ\copyq.exe"
# for execution that need administrator rights:
Set-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Open Hardware Monitor" -Value "$env:ProgramFiles\OpenHardwareMonitor\OpenHardwareMonitor.exe"

# create a terminator start menu shortcut that uses wsl and Xming server
# $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("%APPDATA%\Microsoft\Windows\Start Menu\terminator.lnk")
# $shortcut.TargetPath = "%WINDIR%\System32\bash.exe"
# $shortcut.Arguments = "-c ""DISPLAY=:0 terminator"""
# $shortcut.WindowStyle = 7
# $shortcut.Hotkey = "CTRL+ALT+T"
# $shortcut.Save()

##################
# explorer options
# ----------------
# set Quick access folders
$o = new-object -com shell.application
$o.Namespace("$HOME").Self.InvokeVerb("pintohome")
$o.Namespace("C:\ProgramData\chocolatey\lib\sysinternals").Self.InvokeVerb("pintohome")
$o.Namespace("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools").Self.InvokeVerb("pintohome")
Set-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "HideFileExt" -Value 0 -ea SilentlyContinue
Set-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Value 1 -ea SilentlyContinue
Set-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -ea SilentlyContinue
Set-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Value 0 -ea SilentlyContinue
Set-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideDrivesWithNoMedia" -Value 0
# show preview pane
Set-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\DetailsContainer" -Name "DetailsContainer" -Value ([byte[]](0x02,0x00,0x00,0x00,0x01,0x00,0x00,0x00)) -ea SilentlyContinue
Set-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer" -Name "DetailsContainerSizer" -Value ([byte[]](0x3e,0x01,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x49,0x03,0x00,0x00)) -ea SilentlyContinue
# set default view mode to detail
Remove-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" -recurse -force -ea SilentlyContinue
Remove-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" -recurse -force -ea SilentlyContinue
New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" -ea SilentlyContinue | Out-Null
New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders" -ea SilentlyContinue | Out-Null
New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" -ea SilentlyContinue | Out-Null
New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}" -ea SilentlyContinue | Out-Null
Set-ItemProperty -LiteralPath "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell\{5C4F28B5-F869-4E84-8E60-F11DB97C5CC7}" -Name "Mode" -Value 4 -ea SilentlyContinue
Stop-Process -ProcessName Explorer

Write-Output "done."
