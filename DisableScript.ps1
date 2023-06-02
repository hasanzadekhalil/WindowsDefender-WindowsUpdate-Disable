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

    # Run the downloaded application as administrator
    Start-Process -FilePath $downloadPath -Verb RunAs

}
