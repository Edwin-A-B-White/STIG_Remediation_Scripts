<#
.SYNOPSIS
    This PowerShell script prioritizes ECC Curves for cryptographic security.

.NOTES
    Author          : Edwin White
    LinkedIn        : linkedin.com/in/edwin-white-888650186/
    GitHub          : https://github.com/Edwin-A-B-White
    Date Created    : 02-21-2025
    Last Modified   : 02-21-2025
    Version         : 1.0
    STIG-ID         : WN10-CC-000052

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. : 

.USAGE
    PS C:\> .\ STIG-ID-WN10-CC-000052.ps1

# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit 1
}

# Define the registry path and required values
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002"
$regName = "EccCurves"
$regValue = @("NistP384", "NistP256")  # Prioritizing longer ECC curves first

Write-Host "Checking and configuring ECC Curve Order settings..." -ForegroundColor Yellow

try {
    if (-not (Test-Path $regPath)) {
        Write-Host "Registry path does not exist. Creating it..." -ForegroundColor Yellow
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }
    
    $currentValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
    if ($null -eq $currentValue -or -not ($currentValue -is [array]) -or ($currentValue -join " ") -ne ($regValue -join " ")) {
        Write-Host "Setting $regName to $($regValue -join ", ")..." -ForegroundColor Yellow
        Remove-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue
        New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType MultiString -Force -ErrorAction Stop | Out-Null
        Write-Host "Successfully configured ECC Curve Order." -ForegroundColor Green
    } else {
        Write-Host "ECC Curve Order is already set correctly." -ForegroundColor Green
    }
} catch {
    Write-Host "Error configuring ECC Curve Order: $_" -ForegroundColor Red
    exit 1
}

# Verify the configuration
Write-Host "Verifying configuration..." -ForegroundColor Yellow
try {
    $verifiedValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($verifiedValue -is [array] -and ($verifiedValue -join " ") -eq ($regValue -join " ")) {
        Write-Host "Verification successful: ECC Curve Order is correctly configured." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Verification failed: ECC Curve Order is not correctly configured." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error verifying registry setting: $_" -ForegroundColor Red
    exit 1
}
