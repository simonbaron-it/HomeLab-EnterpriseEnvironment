# Active Directory User Offboarding
**Script:** `Disable-ADUser.ps1`

## Purpose
Automate the secure and auditable offboarding of standard Active Directory user accounts within the `baron.example.com` domain.

The script disables the account, removes direct security-group memberships, clears contact information, updates the account description and moves the user into the existing `Disabled Users` OU.

The workflow incorporates input validation, privileged-account safeguards, `-WhatIf` previews, pre-change configuration snapshots, post-change verification, error handling and audit logging.

> The account is retained in Active Directory rather than deleted.

## Execution Environment
- <b>Execution server:</b> `MGMT01`
- <b>PowerShell version:</b> `Windows PowerShell 5.1`
- <b>Required module:</b> `ActiveDirectory`
- <b>Target domain:</b> `baron.example.com`
- <b>Domain controllers:</b> `DC01` (default), `DC02` (alternative)
- <b>Required permissions:</b> Delegated permissions to disable and modify standard user accounts, manage their group memberships and move them between approved OUs.

## Offboarding Workflow
1. Account identification and validation
      - Retrieve the target user and existing AD attributes.
      - Confirm connectivity to the expected domain and destination OU.
      - Restrict processing to accounts within approved Finance, HR, IT and Sales user OUs.
      - Reject built-in, protected and privileged accounts.
2. Pre-change configuration snapshot
      - Capture the account's original Distinguished Name, enabled state, direct group memberships and relevant attributes.
      - Save a timestamped JSON snapshot before modifying Active Directory.
3. Account disablement
      - Disable the user using `Disable-ADAccount`.
      - Reference the account by its `ObjectGUID` to ensure the correct object is modified.
4. Group membership removal
      - Retrieve existing direct group memberships.
      - Remove the account from those groups using `Remove-ADGroupMember`.
      - Preserve the account's primary group relationship.
5. Account attribute updates
      - Update the Description field with the offboarding date and reason.
      - Optionally clear manager and contact attributes when `-ClearContactAttributes` is specified.
6. OU relocation
      - Move the account into the `Disabled Users` OU using `Move-ADObject`.
7. Post-change verification
      - Confirm the account is disabled.
      - Confirm the account resides in the `Disabled Users` OU.
      - Confirm that direct group memberships have been removed.
      - Record the final result and any errors.

## Security and Safety Controls
The script includes several safeguards to reduce the risk of unintended changes:
- Privileged-account protection: Excludes accounts outside approved standard-user OUs, built-in administrative accounts, and accounts with protected security-group memberships, including nested privileged memberships.
- `WhatIf` support: Allows proposed changes to be reviewed before execution without modifying Active Directory.
- Confirmation: Uses `SupportsShouldProcess` with `ConfirmImpact = High` to require approval before offboarding.
- Original-state preservation: Saves account information in JSON before the first AD modification.
- Error handling: Uses `try`, `catch` and `finally` blocks to identify failures and record their outcomes.
- Partial-failure handling: Attempts to keep the account disabled if a later offboarding step fails.
- Duplicate execution handling: Skips accounts already disabled, located in `Disabled Users` and without direct group memberships.

## Execution
Preview the offboarding operation:
```powershell
.\Disable-ADUser.ps1 -Identity 'jwilson' -Reason 'Lab offboarding test' -WhatIf
```

Execute after reviewing the preview:

```powershell
.\Disable-ADUser.ps1 -Identity 'jwilson' -Reason 'Lab offboarding test'
```

Execute with optional contact-attribute clearing:

```powershell
.\Disable-ADUser.ps1 -Identity 'jwilson' -Reason 'Lab offboarding test' -ClearContactAttributes
```

## Audit Logging and Configuration Snapshots
The script generates two separate records during an approved offboarding operation.

<b>1. Pre-change JSON snapshot</b>
Location: `C:\LabAutomation\Logs\Offboarding\Snapshots\`
The snapshot preserves the original account configuration, including OU location, group memberships, enabled state and relevant user attributes.

<b>2. Offboarding CSV audit log</b>
Location: `C:\LabAutomation\Logs\Offboarding\`
Each audit entry records the execution timestamp, operator, account identity, domain controller, offboarding reason, removed groups, execution status, snapshot location and any errors.

The script uses the following statuses:

|Status|Description|
|---|---|
|`Preview`|Proposed changes displayed - no modifications performed.|
|`Completed`|Offboarding actions completed and final state verified.|
|`Skipped`|No changes required or the operation was declined.|
|`Failed`|The operation failed before any successful AD modification.|
|`Partial`|Some modifications succeeded, but the workflow did not complete.|

> Preview mode does not create snapshot or audit-log files.

## Validation
The script was run to offboard AD user `James Wilson` (one of the users created using the `New-ADUserFromCSV.ps1` script):

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Disable%20Users%20Script%20-%20PowerShell.png" width="900"/>

`Active Directory Users and Computers` on `DC01` was inspected to verify the changes:

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Disable%20Users%20Script%20-%20ADUC.png" width="900"/>

`C:\LabAutomation\Logs\Offboarding` on `MGMT01` was inspected to verify expected outputs:

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Disable%20Users%20Script%20-%20Logs.png" width="900"/>



