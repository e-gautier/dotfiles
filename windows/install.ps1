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
Stop-Process -ProcessName Explorer

Write-Output "done."
