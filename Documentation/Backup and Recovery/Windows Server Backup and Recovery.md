# Windows Server Backup and Recovery
> This section documents the Phase 2 backup and recovery implementation used to protect critical infrastructure configuration and organisational data within the baron.example.com environment.

## Overview
The implementation covers:
- Active Directory System State backup.
- Backup of shared organisational data hosted on FS01.
- Backup of Group Policy, and other infrastructure configuration.
- Verification that backup jobs complete successfully.
- Recovery testing for representative infrastructure and file-service scenarios.

> PowerShell-based configuration backup automation is documented separately in [PowerShell Automation].

### Backup Design

|Component|Protected Data|Backup Target|Primary Recovery purpose|
|---|---|---|---|
|`DC01`|`Active Directory/System State`|`Local B: backup VHDX`|`AD DS, SYSVOL, registry, OS recovery`|
|`DC02`|`Active Directory/System State`|`Local B: backup VHDX`|`Second independent AD recovery source`|
|`FS01`|`E:\CompanyData`|`Local B: backup VHDX`|`OS/config + CompanyData recovery`|
|`Group Policy`|`All GPO's`|`B:\GPOBackups on DC01`|`GPO rollback`|
|`AD Objects`|`Deleted AD Objects`|`AD Recycle Bin`|`User/group/OU recovery`|

## Active Directory Backup
System State backup protects the Active Directory database and supporting Domain Controller components required for recovery.

### Protected Domain Controllers

|Domain Controller|Backup|
|---|---|
|`DC01`|`System State`|
|`DC02`|`System State`|

### Configuration
PowerShell was used to backup both `DC01` & `DC02`.

```PowerShell
wbadmin start backup -backupTarget:B: -allCritical -systemState -vssFull
```

### Validation

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/DC01%20Backup.png" width="900"/>

## File Server Backup

|Component|Backup|
|---|---|
|`FS01`|`System State`|
|`Source`|`E:\CompanyData`|

### Configuration
PowerShell was used to backup `FS01`, including `E:\CompanyData`.

```PowerShell
wbadmin start backup -backupTarget:B: -include:E: -allCritical -systemState -vssFull
```

### Validation

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/FS01%20Backup.png" width="500"/>

## Infrastructure Configuration Backup??
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
A Group Policy backup was used to validate that a GPO could be recovered from exported backup data.
<i>Screenshot?</i>
### Recovery Test 3 — DHCP Configuration Recovery
The exported DHCP configuration was reviewed or restored in a controlled test to verify that scope and option data could be recovered.

<i>Screenshot?</i>
### Active Directory Recovery Readiness
System State backups were verified as available for Domain Controller recovery.

<i>Screenshot?</i>

## Validation Summary
- Critical infrastructure data and configuration are included in the backup design.
- Active Directory System State backups are available for Domain Controller recovery.
- `E:\CompanyData` is backed up separately from the production data volume.
- Group Policy and DHCP configuration can be exported for recovery.
- Deleted file data can be restored successfully from backup.

## Skills Demonstrated
- Configure and validate Active Directory System State backup.
- Protect Windows File Services and shared organisational data.
- Back up Group Policy and DHCP configuration.
- Automate infrastructure configuration backups using PowerShell.
- Validate backup completion and integrity.
- Perform controlled file and configuration recovery testing.
