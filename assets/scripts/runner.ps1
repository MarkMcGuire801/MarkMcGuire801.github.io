#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows 11 STIG Compliance Scanner - V2R7
.DESCRIPTION
    Runs automated checks against DISA STIG controls for Windows 11 V2R7.
    Produces a CSV report and a DISA STIG Viewer 3.x compatible .cklb checklist.
    Does not remediate - scan only.
.PARAMETER OutputPath
    Directory to write reports to. Defaults to .\output\
.PARAMETER Severity
    Filter checks by severity: 'CAT I', 'CAT II', 'CAT III', or 'All' (default)
.EXAMPLE
    .\runner.ps1
    .\runner.ps1 -Severity 'CAT I'
    .\runner.ps1 -OutputPath 'C:\Reports\'
#>

param(
    [string]$OutputPath = '.\output\',
    [ValidateSet('CAT I','CAT II','CAT III','All')]
    [string]$Severity = 'All'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# 1. Load report module
# ---------------------------------------------------------------------------
. (Join-Path $PSScriptRoot 'report.ps1')

# ---------------------------------------------------------------------------
# 2. Load handlers
# ---------------------------------------------------------------------------
$handlersPath = Join-Path $PSScriptRoot 'handlers'
Get-ChildItem -Path $handlersPath -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}

# ---------------------------------------------------------------------------
# 3. Load check definitions
# ---------------------------------------------------------------------------
$checksPath = Join-Path $PSScriptRoot 'checks'
$allChecks  = @()

Get-ChildItem -Path $checksPath -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}

# Gather all variables ending in 'Checks' that are arrays
$allChecks = Get-Variable -Scope Local | Where-Object {
    $_.Name -like '*Checks' -and $_.Value -is [array]
} | ForEach-Object { $_.Value } | ForEach-Object { $_ }

# Apply severity filter if specified
if ($Severity -ne 'All') {
    $allChecks = $allChecks | Where-Object { $_.Severity -eq $Severity }
}

# ---------------------------------------------------------------------------
# 4. Run checks
# ---------------------------------------------------------------------------
$results   = @()
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$hostname  = $env:COMPUTERNAME

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Windows 11 STIG Scanner - V2R7" -ForegroundColor Cyan
Write-Host "  Host     : $hostname" -ForegroundColor Cyan
Write-Host "  Time     : $timestamp" -ForegroundColor Cyan
Write-Host "  Controls : $($allChecks.Count)" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($check in $allChecks) {

    Write-Host "Checking $($check.VulnID) - $($check.Title)" -NoNewline

    try {
        $result = switch ($check.HandlerType) {

            'Registry' {
                $params = $check.CheckParams
                Invoke-RegistryCheck @params
            }

            'Wmi' {
                $params = $check.CheckParams
                Invoke-WmiCheck @params
            }

            'Custom' {
                & $check.CheckScript
            }

            default {
                @{
                    Status = 'Not_Reviewed'
                    Detail = "No handler defined for type '$($check.HandlerType)'"
                }
            }
        }
    }
    catch {
        $result = @{
            Status = 'Error'
            Detail = "Check threw an exception: $_"
        }
    }

    $resultRecord = [PSCustomObject]@{
        VulnID    = $check.VulnID
        RuleID    = $check.RuleID
        Severity  = $check.Severity
        Title     = $check.Title
        Status    = $result.Status
        Detail    = $result.Detail
        Timestamp = $timestamp
        Host      = $hostname
    }

    $results += $resultRecord

    $statusColor = switch ($result.Status) {
        'No Finding'         { 'Green'   }
        'Open Vulnerability' { 'Red'     }
        'Not_Reviewed'       { 'Yellow'  }
        'Error'              { 'Magenta' }
        default              { 'White'   }
    }

    Write-Host "  [$($result.Status)]" -ForegroundColor $statusColor
    Write-Host "  $($result.Detail)" -ForegroundColor DarkGray
    Write-Host ""
}

# ---------------------------------------------------------------------------
# 5. Summary
# ---------------------------------------------------------------------------
$totalChecks = @($results).Count
$notAFinding = @($results | Where-Object Status -eq 'No Finding').Count
$open        = @($results | Where-Object Status -eq 'Open Vulnerability').Count
$notReviewed = @($results | Where-Object Status -eq 'Not_Reviewed').Count
$errors      = @($results | Where-Object Status -eq 'Error').Count

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "  Total Checked       : $totalChecks"
Write-Host "  No Finding          : $notAFinding" -ForegroundColor Green
Write-Host "  Open Vulnerability  : $open"        -ForegroundColor Red
Write-Host "  Not Reviewed        : $notReviewed" -ForegroundColor Yellow
Write-Host "  Errors              : $errors"       -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# 6. Export reports
# ---------------------------------------------------------------------------
Write-Host "Saving reports..." -ForegroundColor Cyan

$exportParams = @{
    Results    = $results
    OutputPath = $OutputPath
    Hostname   = $hostname
    Timestamp  = $timestamp
}

Export-CsvReport @exportParams
Export-CklbReport @exportParams

Write-Host ""
Write-Host "Done." -ForegroundColor Cyan
Write-Host ""
