# PowerShell Infrastructure Automation
> This section documents the development and implementation of PowerShell scripts used to automate routine IT administration, infrastructure health monitoring, Active Directory identity management, configuration backups and operational reporting within the `baron.example.com` home lab.

## Overview
The objective was to build practical PowerShell automation skills while improving the efficiency, consistency and reliability of administrative operations across the Windows Server environment.

Five scripts were developed as part of `Phase 2`, building upon the previously implemented Active Directory, DNS, DHCP, file services, backup/recovery and centralised monitoring infrastructure.

The implementation demonstrates the ability to:
- Automate repetitive Windows Server administration and infrastructure checks.
- Detect service failures and continue monitoring available infrastructure during a server outage.
- Standardise Active Directory user onboarding and offboarding through validated, controlled workflows.
- Automate Group Policy and DHCP configuration exports, capture infrastructure inventories and verify output integrity.
- Analyse centrally forwarded Windows events and generate structured CSV and HTML reports.
- Apply reusable functions, input validation, error handling, -WhatIf safeguards, verification and audit logging.

## Automation Design
The scripts were developed and tested using `Windows PowerShell 5.1` within the existing Hyper-V environment.

|Server|Role in automation|
|---|---|
|`MGMT01`|Central execution host for infrastructure health checking, AD user management and event reporting; Windows Event Collector.|
|`DC01`|AD DS, DNS and DHCP target; local execution host for configuration backups using its dedicated `B:` volume.|
|`DC02`|Additional domain controller and DNS/DHCP failover partner; target for resilience and health validation.|
|`FS01`|File-share, service and storage monitoring target; source of controlled Application events for WEF testing.|
|`CLIENT01`|Domain-joined workstation used for identity, Group Policy and file-access validation.|

### Script Inventory

|Script|Function|
|---|---|
|[`InfrastructureHealthCheck.ps1`](../../Scripts/InfrastructureHealthCheck.ps1)|Infrastructure availability, critical services, DNS, DHCP, AD health and storage checks.|
|[`New-ADUserFromCSV.ps1`](../../Scripts/New-ADUserFromCSV.ps1)|CSV-driven standard-user provisioning, OU placement, group assignment and audit logging.|
|[`Disable-ADUser.ps1`](../../Scripts/Disable-ADUser.ps1)|Controlled account offboarding, direct group removal, OU relocation and audit logging.|
|[`InfrastructureBackup.ps1`](../../Scripts/InfrastructureBackup.ps1)|GPO backups, DHCP exports, infrastructure inventories and integrity verification.|
|[`CentralisedEventReport.ps1`](../../Scripts/CentralisedEventReport.ps1)|Structured analysis and CSV/HTML reporting of centrally forwarded Windows events.|

## Implementation Documentation
> Individual implementation documents provide the workflow, execution commands, validation evidence and limitations for each script.

### 01 — Infrastructure Health Check
**Script:** `InfrastructureHealthCheck.ps1`

Developed a PowerShell script to automate health checks across `DC01`, `DC02`, `FS01` and `MGMT01`, replacing repetitive manual validation with a single reporting workflow.

The script checks management connectivity, critical Windows services, DNS resolution, Active Directory replication and domain-controller health, DHCP failover, file-share availability and disk capacity. Results are displayed progressively and exported as timestamped CSV reports using PASS, WARN and FAIL statuses.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Infrastructure%20Health%20Check.md)

### 02 — Active Directory User Onboarding
**Script:** `New-ADUserFromCSV.ps1`

Developed a CSV-driven onboarding workflow for standard employee accounts in `baron.example.com`.

The script validates employee records, generates usernames, prevents duplicates, selects department-specific OUs, assigns approved Global Security Groups and securely prompts for temporary passwords. Accounts are initially created disabled, configured, then enabled after successful provisioning and verification.

The implementation includes `-WhatIf` previews, password-change enforcement, independent handling of failed records, safeguards for partially provisioned accounts and timestamped CSV audit logs. Validation documented multi-user provisioning, account attributes, group membership, OU placement and generated audit records.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Active%20Directory%20User%20Onboarding.md)

### 03 — Active Directory User Offboarding
**Script:** `Disable-ADUser.ps1`

Developed a controlled and auditable process for removing standard employee access without deleting the account.

The script validates the requested identity, rejects protected or privileged accounts, saves a pre-change JSON snapshot, disables the account, removes direct security-group memberships, updates the description and moves the object into the existing `Disabled Users` OU. Optional contact-attribute removal is supported.

Safeguards include `-WhatIf`, confirmation, post-change verification, repeat-execution checks, partial-failure handling and timestamped CSV auditing. Validation documentation includes offboarding a disposable account, inspecting its state in Active Directory Users and Computers, and reviewing the resulting snapshot and logs.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Active%20Directory%20User%20Offboarding.md)

### 04 — Infrastructure Configuration Backup
**Script:** `InfrastructureBackup.ps1`

Developed an automated configuration-protection workflow executed locally on `DC01` and stored on its dedicated `B:` backup volume.

Each run creates a new timestamped backup directory containing:
- <b>Group Policy backups</b> created using `Backup-GPO -All`.
- <b>DHCP configuration and lease exports</b> created using Export-DhcpServer.
- <b>Configuration inventories</b> covering the AD domain and forest, domain controllers, OUs, groups, DNS zones, DHCP scopes and DHCP failover.
- <b>SHA-256 file hashes</b> and a `BackupManifest.json` recording individual stage results and overall PASS/PARTIAL status.

The workflow validates its execution environment, modules, available storage, export counts, file existence and XML structure. Validation documentation includes a `-WhatIf` preview, generated backup directories and PowerShell execution results.

> These exports complement, but do not replace, the existing Windows Server Backup jobs for System State, critical volumes and file data. The dedicated backup VHDX is not an off-host disaster-recovery copy.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Infrastructure%20Configuration%20Backup.md)

### 05 — Centralised Event Reporting
**Script:** `CentralisedEventReport.ps1`

Developed a read-only reporting workflow that runs on `MGMT01` and analyses events collected in its `ForwardedEvents` log through the existing Windows Event Forwarding subscriptions.

The script identifies Critical/Error events from the System and Application logs and selected identity/security events, including failed logons, user account creation, disablement, deletion, group changes and account lockouts. It extracts relevant event details where available, categorises the results and displays summary counts.

Each run creates a timestamped detailed CSV, summary CSV and browser-readable HTML report. The implementation handles empty reporting windows, query limits, inaccessible logs and incomplete event fields. Its documentation includes controlled `FS01` Application-error and disposable AD account-lifecycle test procedures, with console, report-directory and HTML output evidence.

The reports describe events that have been audited, forwarded, retained and selected by the query; they do not guarantee that every event from every source was collected or provide real-time alerting.

[View Implementation & Validation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/Centralised%20Event%20Reporting.md)

### Execution Environment
The primary automation host is `MGMT01`. `Infrastructure Configuration Backup` is executed locally on `DC01` to access its backup volume.

Scripts require the relevant Windows Server management modules, appropriate Active Directory permissions and connectivity to their target systems.

The local working directory is organised as follows:

```text
C:\LabAutomation\
├── Input\
├── Logs\
├── Output\
└── Scripts\
```

|Script|Primary output|
|---|---|
|`InfrastructureHealthCheck.ps1`|`C:\LabAutomation\Output\InfrastructureHealth-*.csv`|
|`New-ADUserFromCSV.ps1`|`C:\LabAutomation\Logs\Onboarding-*.csv`|
|`Disable-ADUser.ps1`|`C:\LabAutomation\Logs\Offboarding\` (JSON snapshots and CSV audit logs)|
|`InfrastructureBackup.ps1`|`B:\InfrastructureBackups\YYYYMMDD-HHMMSS\` on DC01 (exports and BackupManifest.json)|
|`CentralisedEventReport.ps1`|`C:\LabAutomation\Output\EventReports\` (detailed CSV, summary CSV and HTML)|

> The GitHub repository stores the script source code, sample input files and implementation documentation. Generated logs, credentials and sensitive operational data are excluded.

## Validation Summary

|Script|Validation Performed|
|---|---|
|`InfrastructureHealthCheck.ps1`|Healthy-state checks and controlled DC01 outage; offline server detected while reporting continued for available infrastructure; CSV output generated.|
|`New-ADUserFromCSV.ps1`|Multi-user CSV provisioning; OU and group assignment, account settings and audit-log generation inspected.|
|`Disable-ADUser.ps1`|Disposable user disabled and moved; ADUC inspection and offboarding snapshot/audit files documented.|
|`InfrastructureBackup.ps1`|-WhatIf execution, backup output directories and PowerShell export results documented.|
|`CentralisedEventReport.ps1`|FS01 Application-error and AD lifecycle validation workflow documented, with PowerShell, output-directory and HTML report evidence.|

> Detailed screenshots, observed results, troubleshooting and limitations are included in the corresponding implementation documents.

## Skills Demonstrated
- Windows PowerShell 5.1 scripting using parameters, functions, arrays, hashtables, loops, conditional logic and reusable code.
- Windows Server administration and remote management using PowerShell, Windows management modules and RSAT.
- Infrastructure health assessment across AD DS, DNS, DHCP, Windows services, SMB and storage.
- Active Directory identity lifecycle management, OU placement, security-group membership and privilege safeguards.
- Safe automation using `-WhatIf`, confirmation, input validation, state verification and structured error handling.
- Configuration export automation using Group Policy, DHCP, Active Directory and DNS cmdlets.
- Backup-output verification, SHA-256 hashing, structured inventories and JSON manifests.
- Windows Event Forwarding analysis using Get-WinEvent, event XML, event classification and time-based filtering.
- Creation of timestamped CSV, JSON and HTML outputs for operational reporting and auditing.
- Controlled validation against normal operations, an infrastructure outage and disposable account lifecycle activity.
