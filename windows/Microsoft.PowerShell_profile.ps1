$Host.UI.RawUI.WindowTitle = "PowerShell $($host.Version.Major)`.$($host.Version.Minor)"
function Prompt {
  "PS " + $env:USERNAME + "@" + $env:COMPUTERNAME + ":" + (Get-Location) + "$ "
}