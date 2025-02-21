<#
.SYNOPSIS
   This PowerShell script disables Windows Telemetry full data collection.

.NOTES
    Author          : Edwin White
    LinkedIn        : linkedin.com/in/edwin-white-888650186/
    GitHub          : https://github.com/Edwin-A-B-White
    Date Created    : 02-21-2025
    Last Modified   : 02-21-2025
    Version         : 1.0
    STIG-ID         : WN10-CC-000205

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. : 

.USAGE
    PS C:\> .\ STIG-ID-WN10-CC-000205.ps1

# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit 1
}

# Define the registry path and required value
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$regName = "AllowTelemetry"
$allowedValues = @(0, 1, 2) # 0 = Security, 1 = Basic, 2 = Enhanced (if using Windows Analytics)
$defaultValue = 1 # Default to Basic

Write-Host "Checking and configuring Windows Telemetry setting..." -ForegroundColor Yellow

try {
    if (-not (Test-Path $regPath)) {
        Write-Host "Registry path does not exist. Creating it..." -ForegroundColor Yellow
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }
    
    $currentValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
    if ($null -eq $currentValue -or -not ($currentValue -is [int]) -or ($currentValue -notin $allowedValues)) {
        Write-Host "Updating Windows Telemetry level to an allowed value..." -ForegroundColor Yellow
        New-ItemProperty -Path $regPath -Name $regName -Value $defaultValue -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-Host "Successfully set Windows Telemetry level to Basic." -ForegroundColor Green
    } else {
        Write-Host "Windows Telemetry level is already set to an acceptable value: $currentValue." -ForegroundColor Green
    }
} catch {
    Write-Host "Error configuring Windows Telemetry: $_" -ForegroundColor Red
    exit 1
}

# Verify the configuration
Write-Host "Verifying configuration..." -ForegroundColor Yellow
try {
    $verifiedValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($verifiedValue -in $allowedValues) {
        Write-Host "Verification successful: Windows Telemetry is set correctly ($verifiedValue)." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Verification failed: Windows Telemetry is set to an incorrect level ($verifiedValue)." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error verifying registry setting: $_" -ForegroundColor Red
    exit 1
}
