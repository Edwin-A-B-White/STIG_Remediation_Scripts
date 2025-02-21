<#
.SYNOPSIS
    This PowerShell script disables Application Compatibility Inventory Collection.

.NOTES
    Author          : Edwin White
    LinkedIn        : linkedin.com/in/edwin-white-888650186/
    GitHub          : https://github.com/Edwin-A-B-White
    Date Created    : 02-21-2025
    Last Modified   : 02-21-2025
    Version         : 1.0
    STIG-ID         : WN10-CC-000175

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. : 

.USAGE
    PS C:\> .\ STIG-ID-WN10-CC-000175.ps1

# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit 1
}

# Define the registry path and required value
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"
$regName = "DisableInventory"
$regValue = 1  # 1 means disabling the inventory collection

Write-Host "Checking and configuring Application Compatibility Program Inventory settings..." -ForegroundColor Yellow

try {
    if (-not (Test-Path $regPath)) {
        Write-Host "Registry path does not exist. Creating it..." -ForegroundColor Yellow
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }
    
    $currentValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
    if ($null -eq $currentValue -or -not ($currentValue -is [int]) -or ($currentValue -ne $regValue)) {
        Write-Host "Setting $regName to $regValue..." -ForegroundColor Yellow
        New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-Host "Successfully disabled Application Compatibility Program Inventory." -ForegroundColor Green
    } else {
        Write-Host "Application Compatibility Program Inventory is already disabled." -ForegroundColor Green
    }
} catch {
    Write-Host "Error configuring Application Compatibility Program Inventory: $_" -ForegroundColor Red
    exit 1
}

# Verify the configuration
Write-Host "Verifying configuration..." -ForegroundColor Yellow
try {
    $verifiedValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($verifiedValue -eq $regValue) {
        Write-Host "Verification successful: Application Compatibility Program Inventory is disabled." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Verification failed: Application Compatibility Program Inventory is not correctly configured." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error verifying registry setting: $_" -ForegroundColor Red
    exit 1
}
