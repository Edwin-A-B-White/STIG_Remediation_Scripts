<#
.SYNOPSIS
    This PowerShell script enables pre-boot authentication for BitLocker.

.NOTES
    Author          : Edwin White
    LinkedIn        : linkedin.com/in/edwin-white-888650186/
    GitHub          : https://github.com/Edwin-A-B-White
    Date Created    : 02-21-2025
    Last Modified   : 02-21-2025
    Version         : 1.0
    STIG-ID         : WN10-00-000031

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. : 

.USAGE
    PS C:\> .\ STIG-ID-WN10-00-000031.ps1

# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit 1
}

# Define the registry path and required values
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"
$registrySettings = @{
    "UseAdvancedStartup" = 1  # Enables advanced startup options
    "UseTPMPIN" = 1           # Requires a startup PIN with TPM
    "UseTPMKeyPIN" = 1        # Requires a startup key and PIN with TPM
}

Write-Host "Configuring BitLocker pre-boot authentication settings..." -ForegroundColor Yellow

try {
    if (-not (Test-Path $regPath)) {
        Write-Host "Registry path does not exist. Creating it..." -ForegroundColor Yellow
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }
    
    foreach ($regName in $registrySettings.Keys) {
        $currentValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
        if ($null -eq $currentValue -or -not ($currentValue -is [int]) -or ($currentValue -ne $registrySettings[$regName])) {
            Write-Host "Setting $regName to $($registrySettings[$regName])..." -ForegroundColor Yellow
            if ($null -eq $currentValue) {
                New-ItemProperty -Path $regPath -Name $regName -Value $registrySettings[$regName] -PropertyType DWord -Force -ErrorAction Stop | Out-Null
            } else {
                Set-ItemProperty -Path $regPath -Name $regName -Value $registrySettings[$regName] -Force -ErrorAction Stop | Out-Null
            }
            Write-Host "Successfully configured $regName." -ForegroundColor Green
        } else {
            Write-Host "$regName is already set correctly." -ForegroundColor Green
        }
    }
} catch {
    Write-Host "Error configuring BitLocker pre-boot authentication: $_" -ForegroundColor Red
    exit 1
}

# Verify the configuration
Write-Host "Verifying configuration..." -ForegroundColor Yellow
try {
    $errors = 0
    foreach ($regName in $registrySettings.Keys) {
        try {
            $verifiedValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
            if ($verifiedValue -eq $registrySettings[$regName]) {
                Write-Host "Verification successful: $regName is set to $verifiedValue." -ForegroundColor Green
            } else {
                Write-Host "Verification failed: $regName is set to $verifiedValue, expected $($registrySettings[$regName])." -ForegroundColor Red
                $errors++
            }
        } catch {
            Write-Host "Verification failed: $regName is missing." -ForegroundColor Red
            $errors++
        }
    }
    if ($errors -eq 0) {
        Write-Host "All settings verified successfully." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Some settings failed verification. Please check manually." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error verifying registry settings: $_" -ForegroundColor Red
    exit 1
}
