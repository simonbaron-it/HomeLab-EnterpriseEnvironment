# Infrastructure Configuration Backup
**Script:** `InfrastructureBackup.ps1`

## Purpose
Developed a PowerShell script to automate Group Policy backups, DHCP configuration exports and infrastructure configuration inventories within the `baron.example.com` home lab.

The script runs locally on `DC01` and stores each execution in a separate timestamped directory on the existing `B:` backup volume.

The automation provides:
- Automated backup of all domain Group Policy Objects.
- Export of DHCP configuration and lease information.
- Active Directory, DNS and DHCP configuration snapshots.
- Pre-flight validation of server, storage and management modules.
- Export verification and SHA-256 file integrity hashes.
- Structured execution results recorded in a JSON manifest.
- `-WhatIf` support, error handling and partial-failure reporting.

> These configuration exports complement, but do not replace, the existing Windows Server Backup jobs protecting System State, critical volumes and file data.

## Execution Environment

|Component|Configuration|
|---|---|
|Execution Server|`DC01`|
|PowerShell Version|`Windows PowerShell 5.1`|
|Required Modules|`ActiveDirectory`, `GroupPolicy`, `DhcpServer`, `DnsServer`|
|Target Domain|`baron.example.com`|
|Configuration Source|`DC01`|
|Backup Destination|`B:\InfrastructureBackups`|
|Permissions|Elevated session with appropriate AD, DHCP, DNS, GPO and backup-volume access|

## Protected Configuration

|Component|Export method|
|---|---|
|Group Policy|`Backup-GPO -All`|
|DHCP configuration and leases|`Export-DhcpServer -Leases`|
|AD domain and forest|`Get-ADDomain`, `Get-ADForest`|
|Domain Controllers|`Get-ADDomainController`|
|Organisational Units|`Get-ADOrganizationalUnit`|
|AD Groups|`Get-ADGroup`|
|DNS zones|`Get-DnsServerZone`|
|DHCP scopes|`Get-DhcpServerv4Scope`|
|DHCP failover|`Get-DhcpServerv4Failover`|

> Configuration inventories are saved using `Export-Clixml`.
> 
> These inventories provide reference information for troubleshooting and rebuilding. They are not substitutes for full Active Directory System State backups or complete DNS zone exports.

## Backup Structure
Each execution generates a separate timestamped directory:

```
B:\InfrastructureBackups\
└── YYYYMMDD-HHMMSS\
    ├── GPO\
    │   └── [GPO backup files]
    ├── DHCP\
    │   └── DHCP-Config-and-Leases.xml
    ├── Config\
    │   ├── AD-Domain.xml
    │   ├── AD-Forest.xml
    │   ├── DomainControllers.xml
    │   ├── OrganisationalUnits.xml
    │   ├── Groups.xml
    │   ├── DNS-Zones.xml
    │   ├── DHCP-Scopes.xml
    │   └── DHCP-Failover.xml
    └── BackupManifest.json
```

> Timestamped directories prevent normal executions from overwriting previous backup sets.

## Backup Workflow

1. Pre-flight validation
- Confirm execution on `DC01`.
- Verify that the `B:` backup volume is accessible.
- Check available disk space against the configured threshold.
- Import the required PowerShell modules.
- Confirm connectivity to the expected Active Directory domain and services.
2. Backup directory creation
- Generate a unique execution timestamp.
- Create separate GPO, DHCP and configuration inventory directories.
3. Group Policy backup
- Determine the expected number of GPOs.
- Execute `Backup-GPO -All`.
- Verify the returned backup count and resulting files.
4. DHCP configuration export
- Export server configuration and DHCP leases.
- Confirm the export file exists and contains data.
- Validate that the XML can be parsed.
5. Configuration snapshots
- Export Active Directory domain and forest information.
- Export Domain Controller, OU and group inventories.
- Export DNS zone, DHCP scope and failover information.
6. File verification
- Verify generated export files.
- Calculate `SHA-256` hashes for the exported files.
7. Manifest generation
- Record individual execution results.
- Store file hashes, backup metadata and an overall completion status.

## GPO Backup

-----

## Execution
Run from an elevated session on `DC01`:

```powershell
.\Invoke-InfrastructureBackup.ps1
```

## Validation
- Confirm the `B:` backup volume is available and has free space.
- Compare GPO backup count against the expected count.
- Confirm DHCP export and configuration snapshots exist and contain data.
- Review the JSON manifest, including any partial failures.

**Execution frequency:** `[MANUAL / SCHEDULED]`  
**Observed results:** `[INSERT RESULTS]`

<i>Add: screenshot of successful backup script and manifest</i>

## GPO Backup
## DHCP Export
## Configuration Snapshot
## Backup Verification
## Manifest
