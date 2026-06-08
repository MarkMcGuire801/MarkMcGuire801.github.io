# =============================================================================
# report.ps1
#
# Reporting module for the Windows 11 STIG Scanner.
# Provides two export functions called by runner.ps1 after all checks complete:
#
#   Export-CsvReport  - timestamped CSV, opens in Excel
#   Export-CklbReport - STIG Viewer 3.x compatible .cklb (JSON) file
#
# Status mapping from display labels to .cklb required values:
#
#   Display label          .cklb value
#   ─────────────────────  ─────────────
#   No Finding          -> not_a_finding
#   Open Vulnerability  -> open
#   Not_Reviewed        -> not_reviewed
#   Error               -> not_reviewed
# =============================================================================


# -----------------------------------------------------------------------------
# Get-NetworkInfo
# Collects IP address and MAC address for the active network adapter.
# Returns a hashtable with IpAddress and MacAddress keys.
# -----------------------------------------------------------------------------
function Get-NetworkInfo {
    try {
        # Get active adapters - exclude loopback, virtual, and disconnected
        $adapter = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration `
                       -ErrorAction Stop |
                   Where-Object {
                       $_.IPEnabled -eq $true -and
                       $_.IPAddress -ne $null -and
                       ($_.IPAddress | Where-Object { $_ -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' })
                   } | Select-Object -First 1

        if ($null -eq $adapter) {
            return @{ IpAddress = ''; MacAddress = '' }
        }

        # Pull the first IPv4 address from the array
        $ipv4 = $adapter.IPAddress | Where-Object { $_ -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' } |
                Select-Object -First 1

        # Format MAC address with colons to match STIG Viewer convention
        $mac = $adapter.MACAddress

        return @{
            IpAddress  = if ($ipv4) { $ipv4 } else { '' }
            MacAddress = if ($mac)  { $mac  } else { '' }
        }
    }
    catch {
        return @{ IpAddress = ''; MacAddress = '' }
    }
}


# -----------------------------------------------------------------------------
# Export-CsvReport
# Writes all results to a timestamped CSV file.
# -----------------------------------------------------------------------------
function Export-CsvReport {
    param(
        [array]$Results,
        [string]$OutputPath,
        [string]$Hostname,
        [string]$Timestamp
    )

    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }

    $filename   = "STIG_Scan_${Hostname}_$($Timestamp -replace '[ :]', '-').csv"
    $reportFile = Join-Path $OutputPath $filename

    $Results | Export-Csv -Path $reportFile -NoTypeInformation

    Write-Host "  CSV  : $reportFile" -ForegroundColor Cyan
    return $reportFile
}


# -----------------------------------------------------------------------------
# Export-CklbReport
# Writes results to a DISA STIG Viewer 3.x compatible .cklb file.
#
# The .cklb format is JSON. Only the fields that carry scan results are
# populated dynamically — status, finding_details, and comments.
# All other rule fields are built from the check definition metadata.
# Fields required by the schema but not available from a local scan
# (ccis, srg_id, check_content, etc.) are left as empty strings or
# empty arrays so STIG Viewer can open the file without errors.
# -----------------------------------------------------------------------------
function Export-CklbReport {
    param(
        [array]$Results,
        [string]$OutputPath,
        [string]$Hostname,
        [string]$Timestamp
    )

    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }

    $filename = "STIG_Scan_${Hostname}_$($Timestamp -replace '[ :]', '-').cklb"
    $cklbFile = Join-Path $OutputPath $filename

    # Collect network info for the asset block
    $netInfo = Get-NetworkInfo

    # --- Map display status to .cklb status values ---
    function ConvertTo-CklbStatus {
        param([string]$DisplayStatus)
        switch ($DisplayStatus) {
            'No Finding'         { 'not_a_finding' }
            'Open Vulnerability' { 'open'          }
            'Not_Reviewed'       { 'not_reviewed'  }
            default              { 'not_reviewed'  }
        }
    }

    # --- Map CAT severity to .cklb severity values ---
    function ConvertTo-CklbSeverity {
        param([string]$Severity)
        switch ($Severity) {
            'CAT I'   { 'high'   }
            'CAT II'  { 'medium' }
            'CAT III' { 'low'    }
            default   { 'medium' }
        }
    }

    # --- Build a rule object for each result ---
    # Fields are matched to the schema observed in a STIG Viewer 3.7 export.
    # Only status, finding_details, and comments carry scan-generated data.
    $rules = $Results | ForEach-Object {
        $r          = $_
        $cklbStatus = ConvertTo-CklbStatus   -DisplayStatus $r.Status
        $severity   = ConvertTo-CklbSeverity -Severity      $r.Severity

        [ordered]@{
            group_id_src  = $r.VulnID
            group_tree    = @(
                [ordered]@{
                    id          = $r.VulnID
                    title       = ''
                    description = '<GroupDescription></GroupDescription>'
                }
            )
            group_id       = $r.VulnID
            severity       = $severity
            group_title    = $r.Title
            rule_id_src    = $r.RuleID
            rule_id        = ($r.RuleID -replace '_rule$', '')
            rule_version   = ''
            rule_title     = $r.Title
            fix_text       = ''
            weight         = '10.0'
            check_content  = ''
            check_content_ref = [ordered]@{
                href = 'Microsoft_Windows_11__STIG.xml'
                name = 'M'
            }
            classification             = 'Unclassified'
            discussion                 = ''
            false_positives            = ''
            false_negatives            = ''
            documentable               = 'false'
            security_override_guidance = ''
            potential_impacts          = ''
            third_party_tools          = ''
            ia_controls                = ''
            responsibility             = ''
            mitigations                = ''
            mitigation_control         = ''
            legacy_ids                 = @()
            ccis                       = @()
            reference_identifier       = '5471'
            uuid                       = [System.Guid]::NewGuid().ToString()
            stig_uuid                  = '211738f4-32ca-46a7-b82a-78e7fa72b7c0'
            status                     = $cklbStatus
            overrides                  = [ordered]@{}
            comments                   = "Automated check performed by STIG Scanner on $($r.Timestamp)"
            finding_details            = $r.Detail
            srg_id                     = ''
        }
    }

    # --- Assemble the top-level .cklb document ---
    $cklb = [ordered]@{
        title   = "Windows 11 STIG Scan - $Hostname"
        id      = [System.Guid]::NewGuid().ToString()
        stigs   = @(
            [ordered]@{
                stig_name            = 'Microsoft Windows 11 Security Technical Implementation Guide'
                display_name         = 'Microsoft Windows 11'
                stig_id              = 'Microsoft_Windows_11_STIG'
                release_info         = 'Release: 7 Benchmark Date: 01 Apr 2026'
                version              = '2'
                uuid                 = '211738f4-32ca-46a7-b82a-78e7fa72b7c0'
                reference_identifier = '5471'
                size                 = $Results.Count
                rules                = @($rules)
            }
        )
        active      = $true
        mode        = 1
        has_path    = $false
        target_data = [ordered]@{
            target_type       = 'Computing'
            host_name         = $Hostname
            ip_address        = $netInfo.IpAddress
            mac_address       = $netInfo.MacAddress
            fqdn              = $Hostname
            comments          = "Generated by STIG Scanner on $Timestamp"
            role              = 'Workstation'
            is_web_database   = $false
            technology_area   = ''
            web_db_site       = ''
            web_db_instance   = ''
            classification    = $null
        }
        cklb_version = '1.0'
    }

    # --- Serialize to JSON and write UTF-8 without BOM ---
    # ConvertTo-Json -Compress removes whitespace for a compact single-line file.
    # UTF8Encoding($false) explicitly disables the BOM that .NET adds by default,
    # which would break JSON parsers including STIG Viewer.
    $json     = $cklb | ConvertTo-Json -Depth 10 -Compress
    $encoding = New-Object System.Text.UTF8Encoding $false

    [System.IO.File]::WriteAllText($cklbFile, $json, $encoding)

    Write-Host "  CKLB : $cklbFile" -ForegroundColor Cyan
    return $cklbFile
}
