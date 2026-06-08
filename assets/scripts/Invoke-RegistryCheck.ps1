function Invoke-RegistryCheck {
    <#
    .SYNOPSIS
        Checks a registry value against an expected value.
    .PARAMETER Hive
        Registry hive (e.g. HKLM, HKCU)
    .PARAMETER Path
        Registry key path (without hive)
    .PARAMETER ValueName
        Name of the registry value to check
    .PARAMETER ExpectedValue
        The value that constitutes a compliant state
    .PARAMETER Operator
        Comparison operator: 'eq' (default), 'ge', 'le', 'gt', 'lt'
    #>
    param(
        [string]$Hive,
        [string]$Path,
        [string]$ValueName,
        $ExpectedValue,
        [string]$Operator = 'eq'
    )

    $fullPath = "${Hive}:\${Path}"

    try {
        $actualValue = (Get-ItemProperty -Path $fullPath -Name $ValueName -ErrorAction Stop).$ValueName
    }
    catch {
        return @{
            Status  = 'Open Vulnerability'
            Detail  = "Registry path or value not found: $fullPath\$ValueName"
        }
    }

    $compliant = switch ($Operator) {
        'eq' { $actualValue -eq $ExpectedValue }
        'ge' { $actualValue -ge $ExpectedValue }
        'le' { $actualValue -le $ExpectedValue }
        'gt' { $actualValue -gt $ExpectedValue }
        'lt' { $actualValue -lt $ExpectedValue }
        default { $false }
    }

    if ($compliant) {
        return @{
            Status  = 'No Finding'
            Detail  = "Value '$ValueName' is '$actualValue' (expected '$ExpectedValue')"
        }
    }
    else {
        return @{
            Status  = 'Open Vulnerability'
            Detail  = "Value '$ValueName' is '$actualValue' (expected '$ExpectedValue')"
        }
    }
}
