<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Edwin White
    LinkedIn        : linkedin.com/in/edwin-white-888650186/
    GitHub          : https://github.com/Edwin-A-B-White
    Date Created    : 02-21-2025
    Last Modified   : 02-21-2025
    Version         : 1.0
    STIG-ID         : WN10-AU-000500

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. : 

.USAGE
    PS C:\> .\STIG-ID-WN10-AU-000500.ps1

# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit 1
}

# Define the registry path and required value
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
$regName = "MaxSize"
$regValue = 32768  # Value in KB

Write-Host "Checking and configuring the Application event log size..." -ForegroundColor Yellow

try {
    if (-not (Test-Path $regPath)) {
        Write-Host "Registry path does not exist. Creating it..." -ForegroundColor Yellow
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }
    
    $currentValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
    if ($null -eq $currentValue) {
        Write-Host "Registry property does not exist. Creating it..." -ForegroundColor Yellow
        New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-Host "Successfully created and set Application event log size to $regValue KB." -ForegroundColor Green
    } elseif ($currentValue -lt $regValue) {
        Write-Host "Updating Application event log size to $regValue KB..." -ForegroundColor Yellow
        Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -ErrorAction Stop
        Write-Host "Successfully updated Application event log size to $regValue KB." -ForegroundColor Green
    } else {
        Write-Host "Application event log size is already set to $currentValue KB or greater." -ForegroundColor Green
    }
} catch {
    Write-Host "Error configuring Application event log size: $_" -ForegroundColor Red
    exit 1
}

# Verify the configuration
Write-Host "Verifying configuration..." -ForegroundColor Yellow
try {
    $verifiedValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($verifiedValue -ge $regValue) {
        Write-Host "Verification successful: Application event log size is set to $verifiedValue KB." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Verification failed: Application event log size is set to $verifiedValue KB, which is below the required threshold." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error verifying registry setting: $_" -ForegroundColor Red
    exit 1
}
