#Requires -RunAsAdministrator

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

$URL = "https://github.com/e-gautier/dotfiles.git"
$FOLDER = "$HOME\.dotfiles"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

if (-not (Test-Path -Path $FOLDER)) {
  git clone --recursive $URL $FOLDER
}

powershell -File "$FOLDER\windows\install.ps1"
