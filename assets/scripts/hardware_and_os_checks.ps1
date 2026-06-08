# =============================================================================
# checks\hardware_and_os_checks.ps1
#
# Control definitions for hardware and OS baseline STIG requirements.
# Each entry maps directly to a Vuln ID from the Win 11 V2R7 XCCDF.
#
# To add a new control:
#   1. Copy an existing hashtable block
#   2. Update the VulnID, RuleID, Title, Severity, and CheckParams fields
#   3. Set HandlerType to the appropriate handler
#   4. The runner will pick it up automatically on next execution
# =============================================================================

$HardwareAndOsChecks = @(

    @{
        VulnID      = 'V-253254'
        RuleID      = 'SV-253254r991589_rule'
        Title       = 'Domain-joined systems must use Windows 11 Enterprise Edition 64-bit version.'
        Severity    = 'CAT II'
        HandlerType = 'Custom'

        # Custom check: two separate WMI properties must both be compliant.
        # Win32_OperatingSystem.OperatingSystemSKU 4 = Enterprise, 125 = Enterprise LTSC
        # Win32_OperatingSystem.OSArchitecture must contain '64-bit'
        CheckScript = {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop

            # SKU 4 = Enterprise, 125 = Enterprise LTSC
            $validSkus    = @(4, 125)
            $skuCompliant = $os.OperatingSystemSKU -in $validSkus
            $archCompliant = $os.OSArchitecture -like '*64*'

            if ($skuCompliant -and $archCompliant) {
                return @{
                    Status = 'No Finding'
                    Detail = "Edition SKU: $($os.OperatingSystemSKU), Architecture: $($os.OSArchitecture)"
                }
            }
            else {
                $issues = @()
                if (-not $skuCompliant) {
                    $issues += "OS SKU is $($os.OperatingSystemSKU) - not Enterprise (expected 4 or 125)"
                }
                if (-not $archCompliant) {
                    $issues += "Architecture is $($os.OSArchitecture) - must be 64-bit"
                }
                return @{
                    Status = 'Open Vulnerability'
                    Detail = ($issues -join '; ')
                }
            }
        }
    },

    @{
        VulnID      = 'V-253255'
        RuleID      = 'SV-253255r1117271_rule'
        Title       = 'Windows 11 domain-joined systems must have a Trusted Platform Module (TPM) enabled and ready for use.'
        Severity    = 'CAT II'
        HandlerType = 'Custom'

        # Custom check: TPM must be present, enabled, activated, and version 2.0.
        # Win32_Tpm lives in root/cimv2/Security/MicrosoftTpm namespace.
        CheckScript = {
            try {
                $tpm = Get-CimInstance -ClassName Win32_Tpm `
                                       -Namespace 'root/cimv2/Security/MicrosoftTpm' `
                                       -ErrorAction Stop
            }
            catch {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = "TPM WMI query failed - TPM may not be present or accessible: $_"
                }
            }

            if ($null -eq $tpm) {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = 'No TPM device found on this system.'
                }
            }

            $issues = @()

            if (-not $tpm.IsEnabled_InitialValue) {
                $issues += 'TPM is not enabled'
            }
            if (-not $tpm.IsActivated_InitialValue) {
                $issues += 'TPM is not activated'
            }

            # SpecVersion returns a string like "2.0, 0, 1.38" - major version is first segment
            $specVersion   = $tpm.SpecVersion
            $majorVersion  = ($specVersion -split ',')[0].Trim()

            if ($majorVersion -ne '2.0') {
                $issues += "TPM SpecVersion is '$specVersion' - version 2.0 required"
            }

            if ($issues.Count -eq 0) {
                return @{
                    Status = 'No Finding'
                    Detail = "TPM is present, enabled, activated. SpecVersion: $specVersion"
                }
            }
            else {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = ($issues -join '; ')
                }
            }
        }
    },

    @{
        VulnID      = 'V-253256'
        RuleID      = 'SV-253256r991589_rule'
        Title       = 'Windows 11 systems must use UEFI firmware and be configured to run in UEFI mode, not legacy BIOS.'
        Severity    = 'CAT II'
        HandlerType = 'Custom'

        # $env:firmware_type is populated by Windows automatically.
        # Returns 'Uefi', 'Bios', or 'Unknown'.
        # A value of 'Bios' means the system is running in legacy mode - a finding.
        # 'Unknown' is treated as a finding since compliance cannot be confirmed.
        CheckScript = {
            $firmwareType = $env:firmware_type

            switch ($firmwareType) {
                'Uefi' {
                    return @{
                        Status = 'No Finding'
                        Detail = "Firmware type is UEFI."
                    }
                }
                'Bios' {
                    return @{
                        Status = 'Open Vulnerability'
                        Detail = "Firmware type is legacy BIOS. System must be configured to run in UEFI mode."
                    }
                }
                default {
                    return @{
                        Status = 'Open Vulnerability'
                        Detail = "Firmware type could not be determined (reported as '$firmwareType'). Manual review required."
                    }
                }
            }
        }
    },

    @{
        VulnID      = 'V-253257'
        RuleID      = 'SV-253257r991589_rule'
        Title       = 'Windows 11 systems must have Secure Boot enabled.'
        Severity    = 'CAT II'
        HandlerType = 'Custom'

        # Confirm-SecureBootUEFI returns $true if enabled, $false if disabled.
        # It throws an exception on legacy BIOS systems since Secure Boot is a
        # UEFI feature. That exception is caught and reported as a finding.
        CheckScript = {
            try {
                $secureBoot = Confirm-SecureBootUEFI -ErrorAction Stop

                if ($secureBoot -eq $true) {
                    return @{
                        Status = 'No Finding'
                        Detail = "Secure Boot is enabled."
                    }
                }
                else {
                    return @{
                        Status = 'Open Vulnerability'
                        Detail = "Secure Boot is disabled. Enable Secure Boot in the firmware settings."
                    }
                }
            }
            catch {
                # Exception typically means the system does not support Secure Boot
                # (legacy BIOS) or the query was blocked by policy.
                return @{
                    Status = 'Open Vulnerability'
                    Detail = "Secure Boot status could not be queried - system may be running legacy BIOS or Secure Boot is not supported: $_"
                }
            }
        }
    },

    @{
        VulnID      = 'V-253261'
        RuleID      = 'SV-253261r991589_rule'
        Title       = 'Windows 11 systems must use BitLocker to encrypt all fixed disks.'
        Severity    = 'CAT II'
        HandlerType = 'Custom'

        # Get-BitLockerVolume returns all volumes including removable drives.
        # The check filters to Fixed volumes only (DriveType 3) using Win32_LogicalDisk.
        # All fixed volumes must have ProtectionStatus of 'On'.
        CheckScript = {
            try {
                $allVolumes = Get-BitLockerVolume -ErrorAction Stop
            }
            catch {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = "BitLocker query failed. Ensure the BitLocker Drive Encryption feature is installed: $_"
                }
            }

            # Get drive letters for fixed disks only (DriveType 3 = Local Disk)
            $fixedDriveLetters = Get-CimInstance -ClassName Win32_LogicalDisk |
                                 Where-Object { $_.DriveType -eq 3 } |
                                 ForEach-Object { $_.DeviceID }  # e.g. 'C:'

            # Filter BitLocker results to fixed drives only
            $fixedVolumes = $allVolumes | Where-Object {
                $_.MountPoint.TrimEnd('\') -in $fixedDriveLetters
            }

            if (@($fixedVolumes).Count -eq 0) {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = "No fixed volumes found or BitLocker could not enumerate volumes."
                }
            }

            $unprotected = @($fixedVolumes | Where-Object { $_.ProtectionStatus -ne 'On' })

            if ($unprotected.Count -eq 0) {
                $protected = $fixedVolumes | ForEach-Object { "$($_.MountPoint) [$($_.ProtectionStatus)]" }
                return @{
                    Status = 'No Finding'
                    Detail = "All fixed drives are BitLocker protected: $($protected -join ', ')"
                }
            }
            else {
                $unprotectedList = $unprotected | ForEach-Object { "$($_.MountPoint) [$($_.ProtectionStatus)]" }
                return @{
                    Status = 'Open Vulnerability'
                    Detail = "The following fixed drives are NOT BitLocker protected: $($unprotectedList -join ', ')"
                }
            }
        }
    }

    @{
        VulnID      = 'V-253262'
        RuleID      = 'SV-253262r991589_rule'
        Title       = 'Windows 11 systems must use a BitLocker PIN for pre-boot authentication.'
        Severity    = 'CAT II'
        HandlerType = 'Registry'

        # UseTPMPIN controls whether a PIN is required at startup alongside the TPM.
        # Value 1 = require TPM + PIN. Value 0 or absent = TPM only (not compliant).
        CheckParams = @{
            Hive          = 'HKLM'
            Path          = 'SOFTWARE\Policies\Microsoft\FVE'
            ValueName     = 'UseTPMPIN'
            ExpectedValue = 1
            Operator      = 'eq'
        }
    },

    @{
        VulnID      = 'V-253263'
        RuleID      = 'SV-253263r991589_rule'
        Title       = 'Windows 11 systems must use a BitLocker PIN with a minimum length of six digits for pre-boot authentication.'
        Severity    = 'CAT II'
        HandlerType = 'Registry'

        # MinimumPIN sets the minimum PIN length. Must be 6 or greater.
        # Uses 'ge' (greater than or equal) operator so any value of 6+ passes.
        CheckParams = @{
            Hive          = 'HKLM'
            Path          = 'SOFTWARE\Policies\Microsoft\FVE'
            ValueName     = 'MinimumPIN'
            ExpectedValue = 6
            Operator      = 'ge'
        }
    },

    @{
        VulnID      = 'V-253266'
        RuleID      = 'SV-253266r991589_rule'
        Title       = 'Windows 11 systems must be maintained at a supported servicing level.'
        Severity    = 'CAT I'
        HandlerType = 'Custom'

        # Win32_OperatingSystem.BuildNumber gives the OS build as a string.
        # Win32_OperatingSystem.Version gives the full version including revision
        # e.g. "10.0.22621.3958". The minimum compliant build is 22621 (22H2)
        # with revision 380 or greater.
        CheckScript = {
            $os          = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
            $buildNumber = [int]$os.BuildNumber
            $versionParts = $os.Version -split '\.'
            $revision    = if ($versionParts.Count -ge 4) { [int]$versionParts[3] } else { 0 }

            $minBuild    = 22621
            $minRevision = 380

            if ($buildNumber -lt $minBuild) {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = "OS build is $($os.Version). Minimum required build is 22621.380 (Windows 11 22H2). System must be updated."
                }
            }
            elseif ($buildNumber -eq $minBuild -and $revision -lt $minRevision) {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = "OS build is $($os.Version). Build 22621 detected but revision $revision is below minimum required revision 380. Apply pending updates."
                }
            }
            else {
                return @{
                    Status = 'No Finding'
                    Detail = "OS build is $($os.Version). Meets minimum servicing level requirement (22621.380)."
                }
            }
        }
    },

    @{
        VulnID      = 'V-253270'
        RuleID      = 'SV-253270r991589_rule'
        Title       = 'Windows 11 must employ a deny-all permit-by-exception policy to allow the execution of authorized software programs.'
        Severity    = 'CAT II'
        HandlerType = 'Custom'

        # AppLocker enforcement requires two conditions:
        # 1. The Application Identity service (AppIDSvc) must be running.
        # 2. The Exe rule collection must exist and be set to EnforcementMode 2 (Enforce).
        #    EnforcementMode 0/absent = not configured. EnforcementMode 1 = Audit only.
        # Additional collections (Msi, Script, Appx) are checked and reported
        # as informational detail if not enforced.
        CheckScript = {
            $issues  = @()
            $details = @()

            # --- Check 1: Application Identity service ---
            try {
                $svc = Get-Service -Name 'AppIDSvc' -ErrorAction Stop
                if ($svc.Status -ne 'Running') {
                    $issues += "Application Identity service (AppIDSvc) is not running (Status: $($svc.Status))"
                }
                else {
                    $details += "AppIDSvc is running"
                }
            }
            catch {
                $issues += "Application Identity service (AppIDSvc) could not be queried: $_"
            }

            # --- Check 2: AppLocker collection enforcement modes ---
            $srpBase = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SrpV2'

            $collections = [ordered]@{
                Exe    = $true
                Msi    = $false
                Script = $false
                Appx   = $false
            }

            foreach ($collection in $collections.Keys) {
                $keyPath  = Join-Path $srpBase $collection
                $required = $collections[$collection]

                if (-not (Test-Path $keyPath)) {
                    if ($required) {
                        $issues += "AppLocker '$collection' rule collection not found - AppLocker may not be configured"
                    }
                    else {
                        $details += "AppLocker '$collection' collection not configured (optional)"
                    }
                    continue
                }

                try {
                    $mode = (Get-ItemProperty -Path $keyPath -Name 'EnforcementMode' -ErrorAction Stop).EnforcementMode
                }
                catch {
                    $mode = 0
                }

                switch ($mode) {
                    2 {
                        $details += "AppLocker '$collection' is in Enforce mode"
                    }
                    1 {
                        if ($required) {
                            $issues += "AppLocker '$collection' is in Audit mode only - must be set to Enforce"
                        }
                        else {
                            $details += "AppLocker '$collection' is in Audit mode (not enforced)"
                        }
                    }
                    default {
                        if ($required) {
                            $issues += "AppLocker '$collection' EnforcementMode is '$mode' - must be 2 (Enforce)"
                        }
                        else {
                            $details += "AppLocker '$collection' is not configured"
                        }
                    }
                }
            }

            if ($issues.Count -eq 0) {
                return @{
                    Status = 'No Finding'
                    Detail = $details -join '; '
                }
            }
            else {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = ($issues -join '; ') + " | Info: " + ($details -join '; ')
                }
            }
        }
    },

    @{
        VulnID      = 'V-253284'
        RuleID      = 'SV-253284r991589_rule'
        Title       = 'Windows 11 must have an antivirus program installed and enabled.'
        Severity    = 'CAT II'
        HandlerType = 'Custom'

        # Get-MpComputerStatus queries Windows Defender.
        # Both the AV service and real-time protection must be active.
        CheckScript = {
            try {
                $defender = Get-MpComputerStatus -ErrorAction Stop
            }
            catch {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = "Windows Defender status could not be queried. The feature may not be installed or a third-party AV may have disabled it: $_"
                }
            }

            $issues  = @()
            $details = @()

            if (-not $defender.AMServiceEnabled) {
                $issues += "Windows Defender Antimalware Service is not enabled"
            }
            else {
                $details += "Antimalware service enabled"
            }

            if (-not $defender.RealTimeProtectionEnabled) {
                $issues += "Real-time protection is disabled"
            }
            else {
                $details += "Real-time protection enabled"
            }

            $sigAge = $defender.AntivirusSignatureAge
            $details += "Signature age: $sigAge day(s)"

            if ($issues.Count -eq 0) {
                return @{
                    Status = 'No Finding'
                    Detail = $details -join '; '
                }
            }
            else {
                return @{
                    Status = 'Open Vulnerability'
                    Detail = ($issues -join '; ') + " | Info: " + ($details -join '; ')
                }
            }
        }
    }

)
