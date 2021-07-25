#Requires -RunAsAdministrator

# enable firewall with default block
Set-NetFirewallProfile -All -Enabled True
Set-NetFirewallProfile -All -DefaultInboundAction Block -DefaultOutboundAction Block -NotifyOnListen True -AllowUnicastResponseToMulticast True -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log

# remove all existing rules
Remove-NetFirewallRule -All

# add firewall rules
# allow System to map SMB volumes
New-NetFirewallRule -DisplayName "System" -Direction Outbound -Program "System" -Action Allow
# allow svchost to allow DNS, DHCP...
New-NetFirewallRule -DisplayName "svchost" -Direction Outbound -Program "%SystemRoot%\System32\svchost.exe" -Action Allow
New-NetFirewallRule -DisplayName "Powershell" -Direction Outbound -Program "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Action Allow
New-NetFirewallRule -DisplayName "Chocolatey" -Direction Outbound -Program "%ALLUSERSPROFILE%\chocolatey\choco.exe" -Action Allow
New-NetFirewallRule -DisplayName "Firefox" -Direction Outbound -Program "%ProgramFiles%\Mozilla Firefox\firefox.exe" -Action Allow
New-NetFirewallRule -DisplayName "Jetbrains toolbox" -Direction Outbound -Program "%USERPROFILE%\AppData\Local\JetBrains\Toolbox\bin\jetbrains-toolbox.exe" -Action Allow
New-NetFirewallRule -DisplayName "Steam" -Direction Outbound -Program "%ProgramFiles% (x86)\Steam\Steam.exe" -Action Allow
New-NetFirewallRule -DisplayName "Steam web helper" -Direction Outbound -Program "%ProgramFiles% (x86)\Steam\bin\cef\cef.win7x64\steamwebhelper.exe" -Action Allow
New-NetFirewallRule -DisplayName "Syncthing" -Direction Outbound -Program "%APPDATA%\SyncTrayzor\syncthing.exe" -Action Allow
New-NetFirewallRule -DisplayName "SyncTrayzor" -Direction Outbound -Program "%ProgramFiles%\SyncTrayzor\SyncTrayzor.exe" -Action Allow
New-NetFirewallRule -DisplayName "VSCodium" -Direction Outbound -Program "%USERPROFILE%\AppData\Local\Programs\VSCodium\VSCodium.exe" -Action Allow

# install chocolatey
if (!(Test-Path -Path "$env:ProgramData\Chocolatey")) {
  Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# install binaries
Set-Variable -Name "BINARY_INSTALL" -Value 'Get-Content "$HOME\dotfiles\windows\binaries" | ForEach-Object{($_ -split "\r\n")[0]} | ForEach-Object{choco install -y --accept-license $_}'
$CHOICE = Read-Host "Install binaries ([Y]/n)? "
switch ($CHOICE) {
  { 'n', 'N' -contains $_ } { break }
  Default { Invoke-Expression $BINARY_INSTALL; break }
}

# symlinks
New-Item -Force -Path $HOME\AppData\Roaming\VSCodium\User\settings.json -ItemType SymbolicLink -Value $HOME\dotfiles\vscodium\settings.json
New-Item -Force -Path $HOME\AppData\Roaming\VSCodium\User\keybindings.json -ItemType SymbolicLink -Value $HOME\dotfiles\vscodium\keybindings.json
New-Item -Force -Path $HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -ItemType SymbolicLink -Value $HOME\dotfiles\windows\Microsoft.PowerShell_profile.ps1

# install vscode extensions
Set-Variable -Name "VSCODE_EXTENSIONS_INSTALL" -Value 'Get-Content $HOME\dotfiles\vscode\extensions | ForEach-Object{($_ -split "\r\n")[0]} | ForEach-Object{codium --install-extension $_}'
$CHOICE = Read-Host "Install VScode extensions ([Y]/n)? "
switch ($CHOICE) {
  { 'y', 'Y' -contains $_ } { Invoke-Expression $VSCODE_EXTENSIONS_INSTALL; break }
  { 'n', 'N' -contains $_ } { }
  Default { Invoke-Expression $VSCODE_EXTENSIONS_INSTALL; break }
}

# disable VSCodium firewall rule
Disable-NetFirewallRule -DisplayName "VSCodium"

# set run at startup registries
# for userland execution:
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SyncTrayzor" -Value """$env:ProgramFiles\SyncTrayzor\SyncTrayzor.exe"" -minimized"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "CopyQ" -Value "${env:ProgramFiles(x86)}\CopyQ\copyq.exe"
# for execution that need administrator rights:
Set-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Open Hardware Monitor" -Value "$env:ProgramFiles\OpenHardwareMonitor\OpenHardwareMonitor.exe"

# create a terminator start menu shortcut that uses wsl and Xming server
$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("%APPDATA%\Microsoft\Windows\Start Menu\terminator.lnk")
$shortcut.TargetPath = "%WINDIR%\System32\bash.exe"
$shortcut.Arguments = "-c ""DISPLAY=:0 terminator"""
$shortcut.WindowStyle = 7
$shortcut.Hotkey = "CTRL+ALT+T"
$shortcut.Save()

Write-Output "done."
