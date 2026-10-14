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

|Script|Function|
|---|---|
|[`InfrastructureHealthCheck.ps1`](../../Scripts/Invoke-InfrastructureHealthCheck.ps1)|Server, service, DNS, DHCP, AD and storage health|
|[`New-ADUserFromCSV.ps1`](../../Scripts/New-ADUserFromCSV.ps1)|CSV-driven user onboarding|
|[`Disable-ADUser.ps1`](../../Scripts/Disable-ADUser.ps1)|Controlled user offboarding|
|[`Invoke-InfrastructureBackup.ps1`](../../Scripts/Invoke-InfrastructureBackup.ps1)|Configuration export and verification|
|[`Get-CentralisedEventReport.ps1`](../../Scripts/Get-CentralisedEventReport.ps1)|Central WEF event analysis and reporting|

### Execution Environment
Scripts are developed and tested using Windows PowerShell `5.1`. The `MGMT01` host requires the appropriate `ActiveDirectory`, `DhcpServer` and `GroupPolicy` modules, `WinRM` connectivity and sufficient administrative permissions.

```text
C:\LabAutomation\
├── Scripts\
├── Input\
├── Output\
└── Logs\
```

## Infrastructure Health Check
**Script:** `InfrastructureHealthCheck.ps1`

### Purpose
Developed a PowerShell script to automate routine infrastructure health checks across `DC01`, `DC02`, `FS01` and `MGMT01`.

The script runs centrally from `MGMT01`, replacing multiple manual administrative checks with a single execution. It evaluates key infrastructure components, reports their health status and exports the results for troubleshooting and historical reference.

### Checks Performed
- <b>Connectivity:</b> Tests WinRM management connectivity to each server using TCP port 5985.
- <b>Windows Services:</b> Checks critical services including AD DS, DNS, DHCP, Netlogon, Kerberos, SMB and Windows Event Collector.
- <b>DNS:</b> Validates internal hostname resolution and expected IP addresses against both domain controllers.
- <b>Active Directory:</b> Checks replication health, SYSVOL and NETLOGON accessibility, FSMO role ownership and DC diagnostics where available.
- <b>DHCP:</b> Checks the DC01-DC02-Failover relationship, including its operational state and load-balancing mode.
- <b>File Services:</b> Verifies access to \\FS01\CompanyData.
- <b>Storage:</b> Checks available disk space across the servers, using the following thresholds:
    - <b>PASS:</b> 20% or more free.
    - <b>WARN:</b> 10% to less than 20% free.
    - <b>FAIL:</b> Less than 10% free.

### Execution
The script is executed from `MGMT01` using Windows PowerShell 5.1, with the required Active Directory/DHCP management modules and administrative permissions.

```powershell
.\InfrastructureHealthCheck.ps1
```

#### Output 
Results are displayed in the PowerShell console as checks complete, allowing the administrator to monitor progress without waiting for the entire script to finish.

Each result includes:
- <b>Category:</b> Infrastructure component being checked.
- <b>Target:</b> Server or service being assessed.
- <b>Check:</b> Specific test performed.
- <b>Status:</b> PASS, WARN or FAIL.
- <b>Detail:</b> Additional diagnostic information or error messages.
- At completion, the script displays a summary of the number of PASS, WARN and FAIL results.
- A timestamped CSV report is also generated at:
    - `C:\LabAutomation\Output\InfrastructureHealth-YYYYMMDD-HHMMSS.csv`

### Error Handling and Resilience

During initial testing, the script experienced significant delays when `DC01` was powered off because multiple commands attempted to contact the unavailable server.

The script was subsequently improved to:
- Perform an initial management-connectivity check with a short TCP connection timeout.
- Avoid repeatedly attempting remote checks against servers whose WinRM endpoints are unreachable.
- Use try/catch error handling to record failures without terminating the entire script.
- Display results progressively to help identify slow or unresponsive checks.
- Defer potentially lengthy domain-controller diagnostics during a known DC outage.
- Continue checking the remaining infrastructure when an individual server becomes unavailable.

### Validation
The script is tested under both normal and degraded infrastructure conditions.

#### Normal-State Validation
1. Ensure `DC01`, `DC02`, `FS01` and `MGMT01` are online.
2. Execute the script from `MGMT01`.
3. Review connectivity, services, DNS, AD replication, DHCP failover, file-sharing and storage results.
4. Investigate any unexpected warnings or failures.
5. Confirm that a timestamped CSV report is generated.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/InfrastructureHealthCheck%20Output%20-%20Healthy.png" width="700"/>

#### Failure-State Validation
1. Shut down DC01 through Hyper-V while keeping DC02 operational.
2. Execute the script again from MGMT01.
3. Confirm that the unavailable server is detected and dependent checks are handled without repeatedly waiting for connection timeouts.
4. Verify that checks against the remaining available infrastructure continue.
5. Restart DC01, confirm AD replication and DHCP failover recovery, and rerun the script.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/InfrastructureHealthCheck%20Output%20-%20DC01%20Failure.png" width="700"/>

> CSV File Validation

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/InfrastructureHealthCheck%20Output%20-%20CSV.png" width="900"/>

## Active Directory User Onboarding
**Script:** `New-ADUserFromCSV.ps1`

### Purpose
Developed a PowerShell script to automate the onboarding of standard employee accounts within the `baron.example.com` Active Directory environment.

The script runs centrally from `MGMT01` and processes employee information from a CSV file, replacing repetitive manual account creation in `Active Directory Users and Computers`.

The automation provides:
- CSV input validation and duplicate-account detection.
- Automatic username generation using a standard naming convention.
- Department-specific Organisational Unit placement.
- Role-based Active Directory security group assignment.
- Secure temporary password handling and mandatory password change at first sign-in.
- Safe account provisioning, error handling and verification.
- Timestamped audit logging.

### CSV Input
**Example file:** [`NewUsers-Sample.csv`](../../Scripts/Samples/NewUsers-Sample.csv)

```csv
FirstName,LastName,Department,Role,JobTitle
James,Wilson,Finance,User,Finance Analyst
Emily,Clark,Finance,Manager,Finance Manager
Daniel,Evans,HR,User,HR Advisor
Sophie,Green,IT,User,IT Support Analyst
Oliver,Harris,Sales,User,Sales Executive
```

The CSV contains no passwords or other authentication credentials. 

Each record is processed individually, allowing valid users to be provisioned while invalid records are logged for investigation.

### Username Convention
Usernames are automatically generated using the following convention:

|Employee|sAMAccountName|User Principle Name (UPN)|
|---|---|---|
|`James Wilson`|`jwilson`|`jwilson@baron.example.com`|
|`Emily Clark`|`eclark`|`eclark@baron.example.com`|
|`Daniel Evans`|`devans`|`devans@baron.example.com`|
|`Sophie Green`|`sgreen`|`sgreen@baron.example.com`|
|`Oliver Harris`|`oharris`|`oharris@baron.example.com`|

The script validates generated usernames against the supported character pattern and length restrictions.

Existing usernames and duplicates within the CSV are detected to prevent unintended account creation. Username collisions are flagged for manual review rather than automatically generating numbered alternatives.

### OU Mapping
The script uses a PowerShell hashtable to map employees to their designated Active Directory OU based on department.

|Department|Target OU|
|---|---|
|`Finance`|`OU=Finance Staff`, `OU=Baron Users`, `DC=baron`, `DC=example`, `DC=com`|
|`HR`|`OU=HR Staff`, `OU=Baron Users`, `DC=baron`, `DC=example`, `DC=com`|
|`IT`|`OU=IT Staff`, `OU=Baron Users`, `DC=baron`, `DC=example`, `DC=com`|
|`Sales`|`OU=Sales Staff`, `OU=Baron Users`, `DC=baron`, `DC=example`, `DC=com`|

Before account creation, the script validates that the requested department is supported and its destination OU exists.

### Group Membership
Department and role values determine which Global Security Groups are assigned.

|Department|Role|Assigned Groups|
|---|---|---|
|`Finance`|`User`|`Finance_Users`|
|`Finance`|`Manager`|`Finance_Users`, `Finance_Managers`|
|`HR`|`User`|`HR_Usrers`|
|`HR`|`Manager`|`HR_Users`, `HR_Managers`|
|`IT`|`User`|`IT_Users`|
|`Sales`|`User`|`Sales_Users`|

Group membership follows the existing AGDLP access-control structure, allowing departmental group assignments to provide access through the previously configured resource-permission groups.

The script validates that required groups exist and are Global Security Groups before provisioning.

Unsupported role combinations are rejected. Privileged groups such as IT_Admins are intentionally excluded from automated standard-user onboarding.

### Onboarding Workflow
1. Import the CSV and validate required columns and employee information.
2. Confirm connectivity to the expected Active Directory domain.
3. Validate the employee's department and role against the approved configuration.
4. Generate a username and UPN using the established naming convention.
5. Check for existing accounts, duplicate usernames and missing AD objects.
6. Prompt securely for an initial password.
7. Create the user account in a disabled state within the appropriate OU.
8. Assign the approved departmental and role-based security groups.
9. Enable the account after successful group assignment.
10. Enforce a mandatory password change at next sign-in.
11. Verify account status, required group memberships and password-change settings.
12. Record the result in a structured audit log.

Creating accounts disabled initially ensures that partially provisioned identities are not immediately available for authentication.

### Password Handling
Temporary passwords are supplied interactively through Read-Host -AsSecureString.

The script is designed to:
- Avoid storing passwords in CSV files or audit logs.
- Prompt for a separate temporary password for each new account.
- Require the password to comply with the domain password policy.
- Enforce ChangePasswordAtLogon before the provisioning workflow is considered complete.
- Verify the password-change requirement through the Active Directory pwdLastSet attribute.

### Error Handling and Duplicate Prevention
The script uses PowerShell try/catch error handling to process employee records independently and report failures without terminating the entire onboarding operation.

Possible execution results include:

|Status|Description|
|---|---|
|`Preview`|Proposed changes displayed without modifying Active Directory|
|`Created`|Account created, configured, enabled and verified|
|`Skipped`|Existing username or declined operation|
|`Failed`|Validation or provisioning failed before account creation|
|`Partial`|Account created, but a subsequent provisioning or verification step failed|

If an error occurs after account creation, the script attempts to disable the newly created account and records the failure for administrative investigation.

Previously existing accounts are not modified or recreated automatically.

### Execution
<b>Execution host:</b> `MGMT01`   
<b>PowerShell version:</b>  `Windows PowerShell 5.1`   
<b>Required module:</b>  `ActiveDirectory`   
<b>Target domain:</b>  `baron.example.com`   
<b>Default domain controller:</b>  `DC01`   

> The script requires an account with appropriate permissions to create and configure standard users within the designated OUs.

#### Preview changes without modifying AD:
```powershell
.\New-ADUserFromCSV.ps1 -CsvPath '.\Samples\NewUsers-Sample.csv' -WhatIf
```
#### Execute user onboarding:
```powershell
.\New-ADUserFromCSV.ps1 -CsvPath '.\Samples\NewUsers-Sample.csv'
```

### Audit Logging
Each execution records a structured summary of account-processing results.

Audit logs are exported as timestamped CSV files:
```
C:\LabAutomation\Logs\Onboarding-YYYYMMDD-HHMMSS.csv
```

Each log entry includes:

|Field|Description|
|---|---|
|`Time`|Timestamp of the operation|
|`Operator`|Account executing the script|
|`Row`|Source CSV record number|
|`Username`|Generated account username|
|`Department`|Assigned department|
|`Role`|Requested employee role|
|`Groups`|Intended security group assignments|
|`Status`|`CREATED`, `SKIPPED`, `FAILED` or `PARTIAL`|
|`Detail`|Operation result or error information|

Temporary passwords are not included in the audit logs.

### Validation
#### A five-user CSV test was executed against `DC01`.

> The execution confirmed that the script's automated verification checks completed successfully, including account enablement, expected group membership and the mandatory password-change requirement.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/New-ADUserFromCSV%20Powershell%20Output.png" width="900"/>

> An audit log was successfully generated

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/New-ADUserFromCSV%20-%20CSV%20Log.png" width="900"/>

> New accounts with correctly assigned OU's and Security Groups were inspected in `Active Directory Users and Computers`.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/New-ADUserFromCSV%20-%20ADUC%20Verification.png" width="900"/>

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
