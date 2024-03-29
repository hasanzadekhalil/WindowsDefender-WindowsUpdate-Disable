$DefenderStatus = (Get-MpPreference).DisableRealtimeMonitoring

if ($DefenderStatus -eq $false) {
    Write-Host "Defender is Running! All Features of Windows Security need to be disabled manually the first time, please do this first and then run script again!"
    Start-Sleep -Seconds 10
} else {
    Write-Host "Defender is Not Running"
    Write-Host "Windows Update is Disabling..."
    sc.exe config wuauserv start=disabled
    sc.exe stop wuauserv
    $AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
    $AUSettings.NotificationLevel = 1
    $AUSettings.Save
    # Disable Windows Update service using Group Policy
    $groupPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $groupPolicyValueName = "DisableWindowsUpdateAccess"
    $groupPolicyValue = 1

    if (!(Test-Path $groupPolicyPath)) {
        New-Item -Path $groupPolicyPath -Force | Out-Null
    }
    Set-ItemProperty -Path $groupPolicyPath -Name $groupPolicyValueName -Value $groupPolicyValue
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $registryValueName = "NoAutoUpdate"
    $registryValue = 1

    # Create AU registry key if it doesn't exist
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set Windows Update registry value to disable
    Set-ItemProperty -Path $registryPath -Name $registryValueName -Value $registryValue

    # Stop and disable Windows Update service
    Stop-Service -Name "wuauserv"
    # Set Windows Update service startup type to disabled
    Set-Service -Name "wuauserv" -StartupType Disabled
    $wsusServer = "http://localhost:8530"

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUServer" -Value $wsusServer
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUStatusServer" -Value $wsusServer

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ElevateNonAdmins" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetGroup" -Value "WSUS Group"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetGroupEnabled" -Value 1

    Restart-Service -Name "wuauserv"

    $downloadUrl = "https://github.com/jbara2002/windows-defender-remover/releases/download/release_def_12_4_6/DefenderRemover.exe"
    $downloadPath = "$env:TEMP\disable-defender.exe"
    # Download the application
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
    Start-Process -FilePath $downloadPath /Y -Verb RunAs
}
    
