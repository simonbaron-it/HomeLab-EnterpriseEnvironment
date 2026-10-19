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

Includes input validation, duplicate-account detection, `-WhatIf` support and protective handling of partially provisioned accounts.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Active%20Directory%20User%20Onboarding.md)

### 03 — Active Directory User Offboarding
**Script:** `Disable-ADUser.ps1`

Automates account disablement, group membership removal, placement within the `Disabled Users` OU and administrative audit logging.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Active%20Directory%20User%20Offboarding.md)

### 04 — Infrastructure Configuration Backup
**Script:** `InfrastructureBackup.ps1`

Automates GPO backups, DHCP exports and infrastructure configuration snapshots, complementing the existing Windows Server Backup implementation.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Infrastructure%20Configuration%20Backup.md)

### 05 — Centralised Event Reporting
**Script:** `CentralisedEventReport.ps1`

Queries the centrally collected Windows events on `MGMT01` and produce structured infrastructure and security activity reports.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Centralised%20Event%20Reporting.md)

### Execution Environment
The primary automation host is `MGMT01`.

Scripts require the relevant Windows Server management modules, appropriate Active Directory permissions and connectivity to their target systems.

The local working directory is organised as follows:

```text
C:\LabAutomation\
├── Input\
├── Logs\
├── Output\
└── Scripts\
```

> The GitHub repository stores the script source code, sample input files and implementation documentation. Generated logs, credentials and sensitive operational data are excluded.

## Validation Summary

|Script|Validation Performed|
|---|---|
|`Infrastructure Health Check`|Successful reporting during normal operation and a simulated `DC01` outage, including CSV generation.|
|`AD User Onboarding`|Successful multi-user provisioning, account configuration verification and audit-log generation.|
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
