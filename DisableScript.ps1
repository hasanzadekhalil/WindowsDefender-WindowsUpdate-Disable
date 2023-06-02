$DefenderStatus = (Get-MpPreference).DisableRealtimeMonitoring

if ($DefenderStatus -eq $false) {
    Write-Host "Defender is Running! All Features of Windows Security need to be disabled manually the first time, please do this first and then run script again!"
    Start-Sleep -Seconds 10
} else {
    Write-Host "Defender is Not Running"

    $downloadUrl = "https://github.com/qtkite/defender-control/releases/download/v1.5/disable-defender.exe"
    $downloadPath = "$env:TEMP\disable-defender.exe"

    # Download the application
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

    sc.exe config wuauserv start=disabled
    sc.exe stop wuauserv
    $AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
    $AUSettings.NotificationLevel = 1
    $AUSettings.Save

    Start-Process -FilePath $downloadPath -Verb RunAs
    Write-Host "Windows Update is Disabling..."
    # Disable Windows Update service using Group Policy
    $groupPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $groupPolicyValueName = "DisableWindowsUpdateAccess"
    $groupPolicyValue = 1

    if (!(Test-Path $groupPolicyPath)) {
        New-Item -Path $groupPolicyPath -Force | Out-Null
    }

    Set-ItemProperty -Path $groupPolicyPath -Name $groupPolicyValueName -Value $groupPolicyValue

    # Set Windows Update service startup type to disabled
    Set-Service -Name "wuauserv" -StartupType Disabled

    # Stop the Windows Update service
    Stop-Service -Name "wuauserv" -Force

}
