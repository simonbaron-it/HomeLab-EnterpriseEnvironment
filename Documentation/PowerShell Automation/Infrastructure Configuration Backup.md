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
    ├── Config\
    │   ├── AD-Domain.xml
    │   ├── AD-Forest.xml
    │   ├── DomainControllers.xml
    │   ├── OrganisationalUnits.xml
    │   ├── Groups.xml
    │   ├── DNS-Zones.xml
    │   ├── DHCP-Scopes.xml
    │   └── DHCP-Failover.xml
    ├── DHCP\
    │   └── DHCP-Config-and-Leases.xml
    ├── GPO\
    │   └── [GPO backup files]
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
The script uses `Backup-GPO -All` to back up every Group Policy Object in the domain.

Before execution, the script records the expected GPO count.

Following the backup, the number of returned GPO backups is compared against the expected count, and the resulting backup files are checked.

An unsuccessful operation or count mismatch is recorded as a failed backup stage.

## DHCP Export
The script exports DHCP server configuration and lease information from `DC01` using `Export-DhcpServer`.

The export is saved as: `DHCP\DHCP-Config-and-Leases.xml`

Validation confirms that the file exists, contains data and can be parsed as XML.

This provides a configuration recovery resource alongside the existing DHCP failover relationship between `DC01` and `DC02`.

## Configuration Snapshot
The script collects infrastructure configuration information using the Active Directory, DNS and DHCP PowerShell modules.

Each inventory is saved as a structured XML file using `Export-Clixml`.

This provides reference information for infrastructure troubleshooting, configuration comparison and potential rebuilding activities.

## Backup Verification
The script validates exported files using multiple checks:
- Expected and actual GPO backup counts.
- Export file existence and non-zero file size.
- DHCP export XML parsing.
- Successful configuration inventory collection.
- SHA-256 hashes of exported files.
- File hashes are recorded in the backup manifest and can be recalculated to identify subsequent file modifications.

## Backup Manifest
At completion, the script generates: `BackupManifest.json`.

The manifest contains:

|Field|Description|
|---|---|
|`StartTimestamp`|Backup execution timestamp|
|`CompletedAt`|Completion timestamp|
|`SourceServer`|Server executing the script|
|`Operator`|Windows account executing the script|
|`Domain`|Target Active Directory domain|
|`OutputPath`|Backup directory|
|`ExpectedGPOs`|GPO count before backup|
|`BackedUpGPOs`|Number of GPO backups returned|
|`Results`|Individual backup operation results|
|`Files`|Exported files, sizes and SHA-256 hashes|
|`OverallStatus`|PASS or PARTIAL|

> The overall status is marked PARTIAL if one or more export stages fail.

## Security and Error Handling
The script includes safeguards to reduce the risk of incomplete or unintended operations:
- <b>Execution restriction:</b> Requires an elevated PowerShell session on `DC01`.
- <b>Storage validation:</b>  Checks that the destination backup volume is accessible and has sufficient available capacity.
- <b>`-WhatIf` support:</b>  Previews the operation without creating backup files or directories.
- <b>Timestamped directories:</b>  Prevents normal backup runs from overwriting previous exports.
- <b>Module validation:</b>  Confirms required management modules are available.
- <b>Error handling:</b>  Uses try/catch to record failures and continue independent export stages.
- <b>Output verification:</b>  Checks backup counts, exported files and XML structure.
- <b>Partial-failure reporting:</b>  Prevents individual stage failures from being reported as an entirely successful run.

> Generated configuration data remains on restricted lab storage and is excluded from the public GitHub repository.

## Execution
<b>Execution host:</b> `DC01`

### Preview execution without creating files

``` powershell
.\InfrastructureBackup.ps1 -WhatIf
```

### Execute configuration backup

``` powershell
.\InfrastructureBackup.ps1
```

### Specify a minimum free-space requirement

``` powershell
.\InfrastructureBackup.ps1 -MinFreeGB 5
```

## Validation
### `WhatIf` Validation

The script is executed using `-WhatIf` to confirm the intended backup destination and pre-flight checks without creating files or modifying existing backup sets.

<img src="../../Images/InfrastructureBackup%20WhatIf%20Output.png" width="900"/>

### Successful Configuration Backup

The script is executed from `DC01`, and the configuration, DHCP and GPO inventory output directories are inspected.

<img src="../../Images/InfrastructureBackup%20Directory%20Output.png" width="900"/>

The resulting PowerShell output is reviewed to confirm the individual export stages completed as expected.

<img src="../../Images/InfrastructureBackup%20PowerShell%20Output.png" width="900"/>
