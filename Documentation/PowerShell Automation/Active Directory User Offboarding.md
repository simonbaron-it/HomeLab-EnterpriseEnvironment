# Active Directory User Offboarding
**Script:** `Disable-ADUser.ps1`

## Purpose
Provide an auditable workflow to disable an account, revoke appropriate direct group memberships and move it to the existing `Disabled Users` OU.

## Offboarding Workflow
1. Identify the user and record their existing state and group memberships.
2. Preview proposed modifications using `-WhatIf`.
3. Disable the account and remove the intended direct group memberships.
4. Optionally clear manager/contact attributes; update the description and reason.
5. Move the account to `Disabled Users`, validate changes and log the result.

## Execution
```powershell
.\Disable-ADUser.ps1 -Identity 'james.wilson' -Reason 'Lab offboarding test' -WhatIf

# After reviewing the preview:
.\Disable-ADUser.ps1 -Identity 'james.wilson' -Reason 'Lab offboarding test'
```

## Validation
- Account `Enabled` value changed to `False`.
- OU location and membership changes confirmed.
- Missing-account and partial-failure scenarios handled appropriately.
- Account-disabled event `4725` checked in centralised logs, where available.

**Observed results:** `[INSERT RESULTS]`

<i>Add: screenshot of WhatIf output and disabled account</i>

## Account Disablement
## Group Removal
## Disabled Users OU
## Audit Logging
## Validation
