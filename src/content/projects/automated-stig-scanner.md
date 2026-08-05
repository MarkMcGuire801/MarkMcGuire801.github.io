---
title: "STIG Implementation — Windows 11 V2R7"
status: "Complete"
tags: ["GRC", "Automation", "PowerShell"]
summary: "An automated compliance tool targeting the Microsoft Windows 11 STIG (V2R7, published by DISA). It follows the RMF workflow: scan a Windows 11 endpoint against STIG requirements, categorize findings by severity (CAT I / II / III), and generate structured reports compatible with DISA STIG Viewer."
order: 1
hasWriteup: true
---

This project implements an automated compliance tool targeting the Microsoft Windows 11 Security Technical Implementation Guide (STIG), Version 2 Release 7, published by the Defense Information Systems Agency (DISA). The tool follows the Risk Management Framework (RMF) workflow by providing three core capabilities: scanning a Windows 11 endpoint against STIG requirements, categorizing findings by severity (CAT I / II / III), and generating structured compliance reports in formats compatible with DISA STIG Viewer so remediation actions can be taken.

Normally the functions of this project would be executed through something like the SCAP Compliance Checker (SCC) Tool or Tenable Nessus. This is a lightweight project meant to serve as a general demonstration of practice with GRC concepts, STIGs, and PowerShell.

> Developed with AI-assisted coding (Claude). All logic, STIG control mappings, architectural decisions, and testing were performed and validated by me with extreme focus on security and system stability.

## Project structure

This project is split into a few different functions that all live within a single root folder, with four distinct function layers.

### Layer 1 — The Runner (`runner.ps1`)

This is the only file that is ever called directly. Its purpose is to orchestrate the functions of all other files.

### Layer 2 — The Reporter (`report.ps1`)

Handles all outputs and gathers some additional information for them such as IP and MAC addresses.

### Layer 3 — The Handlers (`handlers\`)

These are reusable functions that know how to perform a specific type of system query. The registry handler knows how to read a Windows registry key and compare its value. The WMI handler knows how to query Windows system information classes. These tools are blind to specific STIG controls, but many controls use the same underlying check types and logic. They exist to be written once so they can be functional across many different checks that may need them.

### Layer 4 — The Checks (`checks\`)

These files contain the actual STIG control definitions. Each definition is a block of data describing one control: the Vuln ID, Rule ID, Severity, Title, which handler type to use, and the parameters to pass. The check definition does not perform any queries itself — it is purely prescriptive. It describes what needs to be checked and with what methods, and the runner and handlers do the actual work.

## Workflow

Run the following in an Admin PowerShell session:

```powershell
PowerShell -ExecutionPolicy Bypass -File .\runner.ps1
```

`runner.ps1` then executes the following steps:

1. Dot sources `report.ps1` — `Get-NetworkInfo`, `Export-CsvReport`, `Export-CklbReport` now available
2. Dot sources all files in `handlers\` — `Invoke-RegistryCheck` and `Invoke-WmiCheck` now available
3. Dot sources all files in `checks\` — `$HardwareAndOsChecks` (10 controls) now available
4. Collects all `*Checks` variables into `$allChecks`
5. Loops over every control, runs it, collects results
6. Prints summary to console
7. Calls `Export-CsvReport` → saves `.csv` to `output\`; calls `Export-CklbReport` → collects IP/MAC, saves `.cklb` to `output\`

## Current rules covered

- **V-253255** — Windows 11 domain-joined systems must have a TPM enabled and ready for use
- **V-253284** — Windows 11 must have an antivirus program installed and enabled (currently checks for Microsoft Defender AV)
- **V-253270** — Windows 11 must employ a deny-all, permit-by-exception policy to allow the execution of authorized software programs
- **V-253266** — Windows 11 systems must be maintained at a supported servicing level
- **V-253263** — Windows 11 systems must use a BitLocker PIN with a minimum length of six digits for pre-boot authentication
- **V-253262** — Windows 11 systems must use a BitLocker PIN for pre-boot authentication
- **V-253261** — Windows 11 systems must use BitLocker to encrypt all fixed disks
- **V-253257** — Windows 11 systems must have SecureBoot enabled
- **V-253256** — Windows 11 systems must use UEFI firmware and be configured to run in UEFI mode, not legacy BIOS
- **V-253254** — Domain-joined systems must use Windows 11 Enterprise Edition 64-bit version
