# PowerShell Infrastructure Automation
> This section documents the development and implementation of PowerShell scripts used to automate routine IT administration, infrastructure health monitoring, Active Directory identity management, configuration backups and operational reporting within the `baron.example.com` home lab.

## Overview
The objective was to build practical PowerShell automation skills while improving the efficiency, consistency and reliability of administrative operations across the Windows Server environment.

Five scripts were developed as part of `Phase 2`, building upon the previously implemented Active Directory, DNS, DHCP, file services, backup/recovery and centralised monitoring infrastructure.

The objectives of this implementation are to:
- Automate repetitive infrastructure administration tasks.
- Provide consistent health monitoring across Windows servers and services.
- Standardise Active Directory user onboarding and offboarding.
- Automate infrastructure configuration backups and verification.
- Generate operational reports from centrally collected Windows events.
- Implement appropriate input validation, error handling, audit logging and safeguards against unintended changes.

## Automation Design
Scripts are developed and tested using `Windows PowerShell 5.1` within the existing Hyper-V environment.

|Server|Role in automation|
|---|---|
|`MGMT01`|Central execution host for health, user management and event reporting.|
|`DC01`|AD DS/DNS/DHCP target and configuration backup execution host (`B:` volume).|
|`DC02`|AD replication, DNS and DHCP failover validation target.|
|`FS01`|File share, service and storage monitoring target.|
|`CLIENT01`|Test workstation for identity and file access validation.|

### Script Inventory

|Script|Function|
|---|---|
|[`InfrastructureHealthCheck.ps1`](../../Scripts/Invoke-InfrastructureHealthCheck.ps1)|Automated server, service, DNS, DHCP, AD and storage health checks.|
|[`New-ADUserFromCSV.ps1`](../../Scripts/New-ADUserFromCSV.ps1)|CSV-driven Active Directory user provisioning.|
|[`Disable-ADUser.ps1`](../../Scripts/Disable-ADUser.ps1)|Controlled account offboarding and access removal.|
|[`Invoke-InfrastructureBackup.ps1`](../../Scripts/Invoke-InfrastructureBackup.ps1)|GPO, DHCP and infrastructure configuration exports.|
|[`Get-CentralisedEventReport.ps1`](../../Scripts/Get-CentralisedEventReport.ps1)|Structured reports from centrally forwarded Windows events.|

## Implementation Documentation
> Each automation script has its own documentation covering its purpose, design, implementation, execution, error handling and validation.

### 01 — Infrastructure Health Check
**Script:** `InfrastructureHealthCheck.ps1`

Automates infrastructure health checks across `DC01`, `DC02`, `FS01` and `MGMT01`.

The script evaluates core services and availability, providing structured PASS/WARN/FAIL results and timestamped CSV reports.

Testing includes a controlled `DC01` outage to demonstrate failure detection and continued monitoring of surviving infrastructure.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Infrastructure%20Health%20Check.md)

### 02 — Active Directory User Onboarding
**Script:** `New-ADUserFromCSV.ps1`

Automates standard employee account creation from CSV input, including username generation, OU placement, approved security group membership, secure temporary password handling and audit logging.

Includes input validation, duplicate-account detection, -WhatIf support and protective handling of partially provisioned accounts.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Active%20Directory%20User%20Onboarding.md)

### 03 — Active Directory User Offboarding
**Script:** Disable-ADUser.ps1 — Planned

Will automate account disablement, group membership removal, placement within the Disabled Users OU and administrative audit logging.

### 04 — Infrastructure Configuration Backup
**Script:** Invoke-InfrastructureBackup.ps1 — Planned

Will automate GPO backups, DHCP exports and infrastructure configuration snapshots, complementing the existing Windows Server Backup implementation.

### 05 — Centralised Event Reporting
**Script:** Get-CentralisedEventReport.ps1 — Planned

Will query the centrally collected Windows events on MGMT01 and produce structured infrastructure and security activity reports.

### Execution Environment
The primary automation host is `MGMT01`.

Scripts require the relevant Windows Server management modules, appropriate Active Directory permissions and connectivity to their target systems.

The local working directory is organised as follows:

```text
C:\LabAutomation\
├── Scripts\
├── Input\
├── Output\
└── Logs\
```

> The GitHub repository stores the script source code, sample input files and implementation documentation. Generated logs, credentials and sensitive operational data are excluded.

## Validation Summary

|Script|Validation Performed|
|---|---|
|`Infrastructure Health Check`|Successful reporting during normal operation and a simulated DC01 outage, including CSV generation.|
|`AD User Onboarding`|Successful single-user provisioning, account configuration verification and audit-log generation.|
|`AD User Offboarding`|Pending.|
|`Infrastructure Configuration Backup`|Pending.|
|`Centralised Event Reporting`|Pending.|

> Detailed screenshots, observed results, troubleshooting and limitations are included in the corresponding implementation documents.

## Skills Demonstrated
- Windows PowerShell 5.1 scripting and automation.
- Functions, variables, arrays, hashtables and conditional logic.
- Remote administration using PowerShell Remoting and RSAT.
- Active Directory identity and group management.
- Infrastructure health monitoring and troubleshooting.
- Structured reporting and CSV processing.
- Input validation, exception handling and audit logging.
- Testing automation against real infrastructure failure scenarios.



## Active Directory User Offboarding
**Script:** `Disable-ADUser.ps1`
### Purpose
Provide an auditable workflow to disable an account, revoke appropriate direct group memberships and move it to the existing `Disabled Users` OU.

### Offboarding Workflow
1. Identify the user and record their existing state and group memberships.
2. Preview proposed modifications using `-WhatIf`.
3. Disable the account and remove the intended direct group memberships.
4. Optionally clear manager/contact attributes; update the description and reason.
5. Move the account to `Disabled Users`, validate changes and log the result.

### Execution
```powershell
.\Disable-ADUser.ps1 -Identity 'james.wilson' -Reason 'Lab offboarding test' -WhatIf

# After reviewing the preview:
.\Disable-ADUser.ps1 -Identity 'james.wilson' -Reason 'Lab offboarding test'
```

### Validation
- Account `Enabled` value changed to `False`.
- OU location and membership changes confirmed.
- Missing-account and partial-failure scenarios handled appropriately.
- Account-disabled event `4725` checked in centralised logs, where available.

**Observed results:** `[INSERT RESULTS]`

<i>Add: screenshot of WhatIf output and disabled account</i>

### Account Disablement
### Group Removal
### Disabled Users OU
### Audit Logging
### Validation

## Infrastructure Configuration Backup
**Script:** `Invoke-InfrastructureBackup.ps1`
### Purpose
Automate configuration exports that complement, **but do not replace**, existing Windows Server Backup jobs for System State and file data.

### Protected Configuration

| Component | Export method |
|---|---|
| Group Policy | `Backup-GPO -All` |
| DHCP configuration and leases | `Export-DhcpServer` |
| Domain, forest and DC inventory | Active Directory PowerShell cmdlets |
| OU/group, DNS and failover inventory | AD/DNS/DHCP PowerShell cmdlets |
| Verification | Export checks and JSON manifest |

### Backup Structure
```text
B:\InfrastructureBackups\
└── [yyyyMMdd-HHmmss]\
    ├── GPO\
    ├── DHCP\
    ├── Config\
    └── BackupManifest.json
```

### Execution
Run from an elevated session on `DC01`:

```powershell
.\Invoke-InfrastructureBackup.ps1
```

### Validation
- Confirm the `B:` backup volume is available and has free space.
- Compare GPO backup count against the expected count.
- Confirm DHCP export and configuration snapshots exist and contain data.
- Review the JSON manifest, including any partial failures.

**Execution frequency:** `[MANUAL / SCHEDULED]`  
**Observed results:** `[INSERT RESULTS]`

<i>Add: screenshot of successful backup script and manifest</i>

### GPO Backup
### DHCP Export
### Configuration Snapshot
### Backup Verification
### Manifest

## Centralised Event Reporting
**Script:** `Get-CentralisedEventReport.ps1`
### Purpose
Query the `ForwardedEvents` log on `MGMT01` and generate an operational summary of infrastructure and identity/security activity.

### Event Sources
- `Infrastructure-Critical-Errors`: Critical/Error events from Application and System logs.
- `Identity-Security-Events`: selected security events, including `4625`, `4720`, `4725`, `4726` and `4740`.

### Execution
```powershell
.\Get-CentralisedEventReport.ps1 -Hours 24
```

### Validation
1. Generate a controlled Application error on `FS01`.
2. Confirm the event appears in `MGMT01`'s `ForwardedEvents` log.
3. Create/disable a disposable AD account to generate identity events.
4. Confirm the report contains the expected source computer and event IDs.
5. Check any CSV/HTML exports for completeness and readability.

**Output location:** `[INSERT PATH]`  
**Observed results:** `[INSERT RESULTS]`

<i>Add: screenshot of report output / HTML report</i>

### WEF Integration
### Event Filtering
### CSV Reporting
### HTML Reporting

## Integrated Automation Test
| Step | Test | Expected result | Actual result |
|---|---|---|---|
| 1 | Run infrastructure health check | Healthy baseline | `[PENDING]` |
| 2 | Create disposable users via CSV | Correct OU and group placement | `[PENDING]` |
| 3 | Run event report | Account-creation event visible if forwarded | `[PENDING]` |
| 4 | Offboard a disposable account | Disabled, memberships reviewed, moved OU | `[PENDING]` |
| 5 | Run event report | Account-disable event visible if forwarded | `[PENDING]` |
| 6 | Run configuration backup | Exports and manifest verified | `[PENDING]` |
| 7 | Simulate a `DC01` outage | Failures reported; `DC02` remains available | `[PENDING]` |
| 8 | Recover `DC01` | Health checks and replication return to normal | `[PENDING]` |

## Validation Summary
- Infrastructure health validated during normal operation and a controlled DC outage.
- CSV onboarding validated, including invalid/duplicate input handling.
- Account offboarding validated using `-WhatIf` and a disposable user.
- Infrastructure configuration backup and manifest verified.
- Centralised event reporting verified against forwarded events.
- Integrated end-to-end test completed.
- Scripts and screenshots reviewed for secrets before committing.

## Skills Demonstrated
- Develop parameterised PowerShell scripts with reusable functions and structured output.
- Automate Active Directory onboarding, offboarding and group management.
- Validate AD replication, DNS, DHCP, server services and file shares.
- Automate and verify GPO/DHCP configuration exports.
- Analyse centralised Windows events and generate operational reports.
- Apply input validation, exception handling, audit logging and `-WhatIf`.
- Test automation under normal and degraded infrastructure conditions.
