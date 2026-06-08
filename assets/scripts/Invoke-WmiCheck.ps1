function Invoke-WmiCheck {
    <#
    .SYNOPSIS
        Queries a WMI/CIM class and checks a property against an expected value.
    .PARAMETER ClassName
        WMI/CIM class name (e.g. Win32_OperatingSystem, Win32_Tpm)
    .PARAMETER Namespace
        WMI namespace (default: root/cimv2)
    .PARAMETER PropertyName
        Property on the WMI object to check
    .PARAMETER ExpectedValue
        The value that constitutes a compliant state
    .PARAMETER Operator
        Comparison operator: 'eq' (default), 'contains', 'ge', 'le'
    .PARAMETER Filter
        Optional WMI filter string (e.g. "IsEnabled = TRUE")
    #>
    param(
        [string]$ClassName,
        [string]$Namespace = 'root/cimv2',
        [string]$PropertyName,
        $ExpectedValue,
        [string]$Operator = 'eq',
        [string]$Filter = $null
    )

    try {
        $params = @{
            ClassName    = $ClassName
            Namespace    = $Namespace
            ErrorAction  = 'Stop'
        }
        if ($Filter) { $params['Filter'] = $Filter }

        $wmiObject = Get-CimInstance @params | Select-Object -First 1
    }
    catch {
        return @{
            Status = 'Open Vulnerability'
            Detail = "WMI query failed for class '$ClassName' in namespace '$Namespace': $_"
        }
    }

    if ($null -eq $wmiObject) {
        return @{
            Status = 'Open Vulnerability'
            Detail = "No WMI object returned for class '$ClassName' (namespace: $Namespace)"
        }
    }

    $actualValue = $wmiObject.$PropertyName

    $compliant = switch ($Operator) {
        'eq'       { $actualValue -eq $ExpectedValue }
        'contains' { $actualValue -like "*$ExpectedValue*" }
        'ge'       { $actualValue -ge $ExpectedValue }
        'le'       { $actualValue -le $ExpectedValue }
        default    { $false }
    }

    if ($compliant) {
        return @{
            Status = 'No Finding'
            Detail = "Property '$PropertyName' is '$actualValue' (expected '$ExpectedValue')"
        }
    }
    else {
        return @{
            Status = 'Open Vulnerability'
            Detail = "Property '$PropertyName' is '$actualValue' (expected '$ExpectedValue')"
        }
    }
}
