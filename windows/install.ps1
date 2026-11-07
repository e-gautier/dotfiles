#Requires -RunAsAdministrator

$DOTFILES = "$HOME\.dotfiles"

function Update-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

function New-Link($Path, $Target) {
  $item = Get-Item $Path -ErrorAction SilentlyContinue
  if ($item -and -not $item.LinkType) { Move-Item $Path "$Path.bak" -Force }
  New-Item -ItemType Directory -Force (Split-Path $Path) | Out-Null
  New-Item -ItemType SymbolicLink -Force -Path $Path -Value $Target | Out-Null
}

# enable firewall with default block
Set-NetFirewallProfile -All -Enabled True
Set-NetFirewallProfile -All -DefaultInboundAction Block -DefaultOutboundAction Allow -NotifyOnListen True -AllowUnicastResponseToMulticast True -LogFileName "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log"

# install binaries
if ((Read-Host "Install binaries ([Y]/n)?") -notmatch '^n') {
  foreach ($line in Get-Content "$DOTFILES\windows\binaries") {
    if ($line -match '^\s*(#|$)') { continue }
    $id, $source = $line -split '\s+'
    if (-not $source) { $source = 'winget' }
    winget install -e --id $id --source $source --accept-package-agreements --accept-source-agreements
  }
  wsl --install -d Debian --no-launch
  Update-Path
}

# symlinks
New-Link "$env:APPDATA\VSCodium\User" "$HOME\Syncthing\VSCode-user"
New-Link $PROFILE "$DOTFILES\windows\Microsoft.PowerShell_profile.ps1"
New-Link "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "$DOTFILES\windows\microsoft_terminal\settings.json"

# install vscodium extensions
if ((Read-Host "Install VSCodium extensions ([Y]/n)?") -notmatch '^n') {
  $extensions = @{}
  foreach ($line in Get-Content "$DOTFILES\roles\linux\vars\main\vscodium.yml") {
    if ($line -match '^(\w+):') { $key = $Matches[1]; $extensions[$key] = @() }
    elseif ($line -match '^\s+- ([\w.-]+)') { $extensions[$key] += $Matches[1] }
  }
  foreach ($e in $extensions.vscodium_extensions) { codium --install-extension $e }
  foreach ($e in $extensions.vscodium_vsix) {
    $publisher, $name = $e.Split('.')
    curl.exe -sL --compressed -o "$env:TEMP\$e.vsix" "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$name/latest/vspackage"
    codium --install-extension "$env:TEMP\$e.vsix"
  }
}

# run at startup
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SyncTrayzor" -Value """$env:ProgramFiles\SyncTrayzor\SyncTrayzor.exe"" -minimized"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "CopyQ" -Value """$env:ProgramFiles\CopyQ\copyq.exe"""

# quick access folders
$shell = New-Object -ComObject Shell.Application
$sysinternals = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Filter "Microsoft.Sysinternals.Suite_*" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
foreach ($folder in $HOME, $sysinternals.FullName, "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools") {
  if ($folder) { $shell.Namespace($folder).Self.InvokeVerb("pintohome") }
}

Write-Output "done."
