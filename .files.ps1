#Requires -RunAsAdministrator

set-executionpolicy remotesigned

Set-Variable -Name "URL" -Value "https://github.com/e-gautier/dotfiles.git"
Set-Variable -Name "FOLDER" -Value "$HOME\.dotfiles"

if(!(Test-Path -Path $FOLDER)) {
  git clone --recursive $URL $FOLDER
}

powershell $HOME\dotfiles\windows\install.ps1
