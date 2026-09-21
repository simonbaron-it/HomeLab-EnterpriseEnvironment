# Windows Server Backup and Recovery
> This section documents the Phase 2 backup and recovery implementation used to protect critical infrastructure configuration and organisational data within the baron.example.com environment.

## Overview
The implementation covers:
- Active Directory system state backup.
- Backup of shared organisational data hosted on FS01.
- Backup of Group Policy, DHCP and other infrastructure configuration.
- Verification that backup jobs complete successfully.
- Recovery testing for representative infrastructure and file-service scenarios.

> PowerShell-based configuration backup automation is documented separately in [PowerShell Automation].

### Backup Design

|Component|Protected Data|Backup/Recovery Location|Recovery Purpose|
|---|---|---|---|
|`DC01`|`System State + Critical Volumes`|`Dedicated B: backup VHDX`|`AD DS, SYSVOL, registry, OS recovery`|
|`DC02`|`System State + Critical Volumes`|`Dedicated B: backup VHDX`|`Secondary Domain Controller recovery source`|
|`FS01`|`E:\CompanyData + System State + Critical Volumes`|`Dedicated B: backup VHDX`|`File data and server recovery`|
|`Group Policy`|`All GPOs`|`B:\GPOBackups on DC01`|`Individual GPO rollback / restore`|
|`DHCP`|`DHCP server configuration and leases`|`B:\DHCPBackups on DC01`|`Scope and DHCP configuration recovery`|

> Active Directory Recycle Bin is also enabled to provide object-level recovery for accidentally deleted users, groups and organisational units without requiring a full System State restore.
>
> **Lab storage note:** Backup VHDXs are attached as dedicated backup volumes to each virtual machine. In a production environment, backup copies would also be stored on separate/off-host storage to protect against Hyper-V host or underlying storage failure.

## Active Directory Backup
Windows Server Backup was used to protect the Active Directory system state and critical operating system volumes on both Domain Controllers, providing recovery capability for AD DS, SYSVOL, the registry and other required server components.

### Protected Domain Controllers

|Domain Controller|Backup|
|---|---|
|`DC01`|`System State + Critical Volumes`|
|`DC02`|`System State + Critical Volumes`|

### Configuration
`wbadmin` was executed from an elevated PowerShell session on each Domain Controller to create a backup containing system state and all critical volumes.

```PowerShell
wbadmin start backup -backupTarget:B: -allCritical -systemState -vssFull
```

### Validation

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/DC01%20Backup.png" width="900"/>

## File Server Backup
Windows Server Backup was configured on FS01 to protect the shared organisational data stored on `E:\CompanyData` together with the server's system state and critical operating system volumes.

|Component|Backup|
|---|---|
|`FS01`|`System State + Critical Volumes`|
|`Source`|`E:\CompanyData`|

### Configuration
`wbadmin` was executed from an elevated PowerShell session on `FS01` to protect the server's critical volumes, system state and `E:\CompanyData`.

```PowerShell
wbadmin start backup -backupTarget:B: -include:E: -allCritical -systemState -vssFull
```

### Validation

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/FS01%20Backup.png" width="500"/>

## Infrastructure Configuration Backup
Infrastructure configuration is exported separately so key settings can be restored without rebuilding them manually.

### Group Policy
All Group Policy Objects are backed up using PowerShell.

```PowerShell
New-Item `
    -Path "B:\GPOBackups" `
    -ItemType Directory `
    -Force

Backup-GPO `
    -All `
    -Path "B:\GPOBackups" `
    -Comment "Phase 2 Backup & Recovery baseline"
```

### Validation

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/GPO%20Backup.png" width="900"/>

### DHCP
The DHCP server configuration and lease data were exported separately to provide a faster recovery method than restoring an entire Domain Controller.

```PowerShell
New-Item `
    -Path "B:\DHCPBackups" `
    -ItemType Directory `
    -Force

Export-DhcpServer `
    -ComputerName "DC01" `
    -File "B:\DHCPBackups\DHCP-Config.xml" `
    -Leases `
    -Force
```

### Validation

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/DHCP%20Backup.png" width="900"/>

## Recovery Testing
Representative recovery tests were performed to verify that protected data and configuration could be restored successfully.

### Recovery Test 1 — File Recovery
A test file was created within `E:\CompanyData`, backed up, deleted and then restored from backup.

#### Before Deletion
<img src="INSERT-FILE-BEFORE-DELETION-SCREENSHOT" width="900"/>

#### Recovery
<img src="INSERT-FILE-RECOVERY-SCREENSHOT" width="900"/>

#### Restored File
<img src="INSERT-FILE-RESTORE-VALIDATION-SCREENSHOT" width="900"/>

### Recovery Test 2 — Group Policy Recovery
A test Group Policy Object was backed up using `Backup-GPO`, modified or removed, and restored from the exported GPO backup.

<i>Screenshot?</i>

### Recovery Test 3 — DHCP Configuration Recovery
The DHCP configuration export was validated by confirming that the exported backup contained the configured scope, options and lease information.

<i>Screenshot?</i>

### Active Directory Recovery Readiness
System State backups were confirmed as available for both Domain Controllers using Windows Server Backup.

<i>Screenshot?</i>
wbadmin get versions

## Validation Summary
- Critical infrastructure data and configuration are included in the backup design.
- Active Directory System State backups are available for Domain Controller recovery.
- `E:\CompanyData` is protected by Windows Server Backup and stored on the dedicated `B:` backup volume.
- Group Policy and DHCP configuration can be exported for recovery.
- Deleted file data can be restored successfully from backup.

## Skills Demonstrated
- Configure and validate Active Directory System State backup.
- Protect Windows File Services and shared organisational data.
- Back up Group Policy and DHCP configuration.
- Use PowerShell and Windows Server backup tooling to protect infrastructure configuration.
- Validate backup completion and integrity.
- Perform controlled file and configuration recovery testing.
