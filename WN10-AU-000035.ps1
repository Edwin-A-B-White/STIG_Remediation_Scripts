<#
.SYNOPSIS
    This PowerShell script enables auditing of User Account Management failures.

.NOTES
    Author          : Edwin White
    LinkedIn        : linkedin.com/in/edwin-white-888650186/
    GitHub          : https://github.com/Edwin-A-B-White
    Date Created    : 02-21-2025
    Last Modified   : 02-21-2025
    Version         : 1.0
    STIG-ID         : WN10-AU-000035

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. : 

.USAGE
    PS C:\> .\STIG-ID-WN10-AU-000035.ps1


# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit
}

# Enable 'Audit: Force audit policy subcategory settings to override audit policy category settings'
Write-Host "Enabling 'Force audit policy subcategory settings'..." -ForegroundColor Yellow
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "SCENoApplyLegacyAuditPolicy"
$regValue = 1

try {
    if (Test-Path $regPath) {
        $regProperty = Get-ItemProperty -Path $regPath -ErrorAction Stop
        if (-not ($regProperty.PSObject.Properties.Name -contains $regName)) {
            Write-Host "Registry property does not exist. Creating it..." -ForegroundColor Yellow
            New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWord -Force -ErrorAction Stop
            Write-Host "Successfully created and set 'Force audit policy subcategory settings'." -ForegroundColor Green
        } elseif ($regProperty.$regName -ne $regValue) {
            Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -ErrorAction Stop
            Write-Host "Successfully enabled 'Force audit policy subcategory settings'." -ForegroundColor Green
        } else {
            Write-Host "'Force audit policy subcategory settings' is already enabled." -ForegroundColor Green
        }
    } else {
        Write-Host "Registry path does not exist: $regPath" -ForegroundColor Red
        exit
    }
} catch {
    Write-Host "Error modifying registry: $_" -ForegroundColor Red
    exit
}

# Set the audit policy for User Account Management failures
Write-Host "Configuring audit policy for User Account Management failures..." -ForegroundColor Yellow
try {
    $auditPolOutput = & AuditPol /set /subcategory:"User Account Management" /success:enable /failure:enable 2>&1
    Write-Host "Audit policy set command output: $auditPolOutput" -ForegroundColor Cyan
    if ($auditPolOutput -match "The command was successfully executed") {
        Write-Host "Audit policy set successfully." -ForegroundColor Green
    } else {
        Write-Host "Potential issue setting audit policy. Please verify manually." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error configuring audit policy: $_" -ForegroundColor Red
    exit
}

# Verify the configuration
Write-Host "Verifying configuration..." -ForegroundColor Yellow
try {
    $policyCheck = & AuditPol /get /subcategory:"User Account Management" 2>&1
    Write-Host "Audit policy verification output: $policyCheck" -ForegroundColor Cyan
    if ($policyCheck -match "User Account Management\s+.*Success and Failure") {
        Write-Host "Audit policy successfully configured for User Account Management failures." -ForegroundColor Green
    } else {
        Write-Host "Failed to verify audit policy. Please check manually." -ForegroundColor Red
    }
} catch {
    Write-Host "Error verifying audit policy: $_" -ForegroundColor Red
}
