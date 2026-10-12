# PowerShell Infrastructure Automation
> This section documents the development and validation of five PowerShell scripts used to automate routine administration, infrastructure health checking, identity lifecycle management, configuration backup, and operational reporting within the `baron.example.com` environment.

## Overview
The objectives of this implementation are to:
- Automate routine infrastructure health checks across the lab.
- Standardise Active Directory user onboarding and offboarding.
- Automate exports of Group Policy, DHCP and infrastructure configuration.
- Produce structured reports from centrally forwarded Windows events.
- Improve operational consistency, error handling and auditability.

## Automation Design

|Server|Role in automation|
|---|---|
|`MGMT01`|Central execution host for health, user management and event reporting.|
|`DC01`|AD DS/DNS/DHCP target and configuration backup execution host (`B:` volume).|
|`DC02`|AD replication, DNS and DHCP failover validation target.|
|`FS01`|File share, service and storage monitoring target.|
|`CLIENT01`|Test workstation for identity and file access validation.|

### Script Inventory

| Script | Function | Status |
|---|---|---|
| [`Invoke-InfrastructureHealthCheck.ps1`](../../Scripts/Invoke-InfrastructureHealthCheck.ps1) | Server, service, DNS, DHCP, AD and storage health | `[STATUS]` |
| [`New-ADUserFromCSV.ps1`](../../Scripts/New-ADUserFromCSV.ps1) | CSV-driven user onboarding | `[STATUS]` |
| [`Disable-ADUser.ps1`](../../Scripts/Disable-ADUser.ps1) | Controlled user offboarding | `[STATUS]` |
| [`Invoke-InfrastructureBackup.ps1`](../../Scripts/Invoke-InfrastructureBackup.ps1) | Configuration export and verification | `[STATUS]` |
| [`Get-CentralisedEventReport.ps1`](../../Scripts/Get-CentralisedEventReport.ps1) | Central WEF event analysis and reporting | `[STATUS]` |

### Execution Environment
Scripts are developed and tested using Windows PowerShell `5.1`. The management host requires the appropriate `ActiveDirectory`, `DhcpServer` and `GroupPolicy` modules, `WinRM` connectivity and sufficient administrative permissions.

```text
C:\LabAutomation\
├── Scripts\
├── Input\
├── Output\
└── Logs\
```

### Scripting Standards

## Infrastructure Health Check
**Script:** `Invoke-InfrastructureHealthCheck.ps1`
### Purpose
Runs a consolidated set of infrastructure checks against `DC01`, `DC02`, `FS01` and `MGMT01`.
### Checks Performed
- Server reachability and critical Windows services.
- DNS resolution via both domain controllers.
- AD replication status, domain controller health and FSMO role visibility.
- `SYSVOL` and `NETLOGON` share availability.
- DHCP failover state.
- Access to `\\FS01\CompanyData` and disk free-space thresholds.

### Execution
```powershell
.\Invoke-InfrastructureHealthCheck.ps1
```

**Output:** `[DESCRIBE CONSOLE RESULTS, CSV PATH AND STATUS VALUES]`

### Validation
1. Execute with all infrastructure online to record the healthy baseline.
2. Shut down `DC01` in a controlled test, keeping `DC02` available.
3. Confirm affected checks fail cleanly while unaffected services remain healthy.
4. Start `DC01`, verify AD replication and rerun the script.

**Observed results:** `[INSERT RESULTS]`

### Normal-State Validation
<i>Add: screenshot of healthy report</i>
### Failure-State Validation
<i>Add: screenshot of DC01 failure report</i>

## Active Directory User Onboarding
**Script:** `New-ADUserFromCSV.ps1`
### Purpose
Create standard employee accounts from CSV records using validated inputs, department-specific OU placement, security group assignment and audit logging.

### CSV Input
**Example file:** [`NewUsers-Sample.csv`](../../Scripts/Samples/NewUsers-Sample.csv)

```csv
FirstName,LastName,Department,Role,JobTitle
James,Wilson,Finance,User,Finance Analyst
Emily,Clark,Finance,Manager,Finance Manager
Daniel,Evans,HR,User,HR Advisor
```

### Onboarding Workflow
1. Import CSV and validate mandatory fields, department and role.
2. Generate a unique username and UPN using `[USERNAME CONVENTION]`.
3. Create the account in the appropriate OU and assign authorised groups.
4. Set a securely provided initial password and require a change at first sign-in.
5. Write a success/failure audit record without storing passwords.

### OU Mapping
### Group Membership
### Password Handling

### Execution
```powershell
.\New-ADUserFromCSV.ps1 -CsvPath '.\Samples\NewUsers-Sample.csv'
```

### Validation
- User accounts created in the correct OUs.
- Expected security group membership and password-change requirement confirmed.
- Invalid CSV rows and duplicate usernames handled safely.
- Account creation event `4720` checked in `MGMT01`'s forwarded logs, where available.

**Observed results:** `[INSERT RESULTS]`

<i>Add: screenshot of onboarding output and created accounts</i>

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
