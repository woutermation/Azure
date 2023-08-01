$logPath = "C:\ProgramData\DTX\Logs\Winget\Install"
#Check if Logfile Path exist
If (!(Test-Path $logPath)) { New-Item -ItemType Directory -Force -Path $logPath }
# Winget path (System)
$winGet = Get-ChildItem -Path (Join-Path -Path (Join-Path -Path 'C:\Program Files' -ChildPath 'WindowsApps') -ChildPath 'Microsoft.DesktopAppInstaller*_x64*\winget.exe')
# Applications
$allApplicationIDs = "Adobe.Acrobat.Reader.64-bit", "Microsoft.PowerBI", "Microsoft.SQLServerManagementStudio", "Google.Chrome", "SlackTechnologies.Slack"

foreach ($appId in $allApplicationIDs)
{
    Write-Output "Install $appId"
    $logFile = "WinGetLog-$appId-$(Get-Content env:computername).log"
    Start-Process -FilePath "$($winGet.FullName)" -ArgumentList "install $($appId) --silent --accept-package-agreements --scope machine --accept-source-agreements --log `"$($logPath)\$($logFile)`"" -Wait
}
Write-Output "Upgrade all applications"
Start-Process -FilePath "$($winGet.FullName)" -ArgumentList "upgrade --all"

Get-ChildItem $logPath
