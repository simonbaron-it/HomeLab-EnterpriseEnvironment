# Infrastructure Configuration Backup
**Script:** `Invoke-InfrastructureBackup.ps1`

## Purpose
Automate configuration exports that complement, **but do not replace**, existing Windows Server Backup jobs for System State and file data.

## Protected Configuration

| Component | Export method |
|---|---|
| Group Policy | `Backup-GPO -All` |
| DHCP configuration and leases | `Export-DhcpServer` |
| Domain, forest and DC inventory | Active Directory PowerShell cmdlets |
| OU/group, DNS and failover inventory | AD/DNS/DHCP PowerShell cmdlets |
| Verification | Export checks and JSON manifest |

## Backup Structure
```text
B:\InfrastructureBackups\
└── [yyyyMMdd-HHmmss]\
    ├── GPO\
    ├── DHCP\
    ├── Config\
    └── BackupManifest.json
```

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
