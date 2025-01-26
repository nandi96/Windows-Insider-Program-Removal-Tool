# Windows Insider Program Removal Tool (IRT)

# This script is licensed under the GNU General Public License v3.0.

# Title: Windows Insider Program Removal Tool (IRT)
# Version: 1.0
# Release date: 01-26-2025
# Author: nandi96

# Disclaimer
# By using this script, you agree that the author is not responsible for any damage or loss resulting from its use. 
# The script is provided "as is" without any warranties. Use at your own risk. 
# The author is not liable for any direct, indirect, incidental, special, exemplary, or consequential damages. 
# You acknowledge that any harm, whether intentional or accidental, is your own responsibility. 
# By continuing to use this script, you automatically agree to these terms and waive any claims for damages against the author.

# Check if the script is running as administrator
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "Please run the script as an administrator." -ForegroundColor Red
    exit
}

# Remove Windows Insider settings
Write-Host "Removing Windows Insider settings..." -ForegroundColor Yellow
if (Test-Path "HKLM:\SOFTWARE\Microsoft\WindowsSelfHost") {
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsSelfHost" -Recurse -Force
    Write-Host "Windows Insider settings removed." -ForegroundColor Green
} else {
    Write-Host "Windows Insider settings not found." -ForegroundColor Cyan
}

# Remove the registration key
Write-Host "Removing the Windows Insider registration key..." -ForegroundColor Yellow
if (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection") {
    Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Recurse -Force
    Write-Host "Registration key removed." -ForegroundColor Green
} else {
    Write-Host "Registration key not found." -ForegroundColor Cyan
}

# Restart Windows Update service
Write-Host "Restarting Windows Update service..." -ForegroundColor Yellow
Restart-Service -Name "wuauserv"

Write-Host "Windows Insider Program successfully removed." -ForegroundColor Green

# Display Windows information
Write-Host "Displaying Windows information..." -ForegroundColor Yellow
$windowsProductName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
$windowsBuildLabEx = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").BuildLabEx
Write-Host "$windowsProductName ($windowsBuildLabEx)"

# Display Windows product key
$productKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
Write-Host "Windows Product Key: $productKey"

# Add space before the question
Write-Host ""

# Prompt user for DISM /RestoreHealth and sfc /scannow
$response = $null
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Would you like to run DISM /RestoreHealth and sfc /scannow? Select within 10 seconds! (1-Yes, 0-No)" -ForegroundColor Magenta

while ($stopwatch.Elapsed.TotalSeconds -lt 10 -and -not $Host.UI.RawUI.KeyAvailable) {
    Start-Sleep -Milliseconds 500
}

if ($Host.UI.RawUI.KeyAvailable) {
    $response = Read-Host
}

if (-not $response) {
    Write-Host "No response detected in 10 seconds. Stopping script..." -ForegroundColor Red
    break
}

if ($response -eq '1') {
    Write-Host "Running DISM /RestoreHealth..." -ForegroundColor Yellow
    Start-Process -FilePath "DISM.exe" -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" -Wait
    Write-Host "Running sfc /scannow..." -ForegroundColor Yellow
    Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait
    Write-Host "DISM /RestoreHealth and sfc /scannow completed." -ForegroundColor Green
} else {
    Write-Host "DISM /RestoreHealth and sfc /scannow skipped." -ForegroundColor Cyan
}
