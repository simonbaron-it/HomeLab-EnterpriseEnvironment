# Active Directory User Onboarding
**Script:** `New-ADUserFromCSV.ps1`

## Purpose
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

## CSV Input
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

## Username Convention
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

## OU Mapping
The script uses a PowerShell hashtable to map employees to their designated Active Directory OU based on department.

|Department|Target OU|
|---|---|
|`Finance`|`OU=Finance Staff`, `OU=Baron Users`, `DC=baron`, `DC=example`, `DC=com`|
|`HR`|`OU=HR Staff`, `OU=Baron Users`, `DC=baron`, `DC=example`, `DC=com`|
|`IT`|`OU=IT Staff`, `OU=Baron Users`, `DC=baron`, `DC=example`, `DC=com`|
|`Sales`|`OU=Sales Staff`, `OU=Baron Users`, `DC=baron`, `DC=example`, `DC=com`|

> Before account creation, the script validates that the requested department is supported and its destination OU exists.

## Group Membership
Department and role values determine which Global Security Groups are assigned.

|Department|Role|Assigned Groups|
|---|---|---|
|`Finance`|`User`|`Finance_Users`|
|`Finance`|`Manager`|`Finance_Users`, `Finance_Managers`|
|`HR`|`User`|`HR_Users`|
|`HR`|`Manager`|`HR_Users`, `HR_Managers`|
|`IT`|`User`|`IT_Users`|
|`Sales`|`User`|`Sales_Users`|

Group membership follows the existing AGDLP access-control structure, allowing departmental group assignments to provide access through the previously configured resource-permission groups.

The script validates that required groups exist and are Global Security Groups before provisioning.

Unsupported role combinations are rejected. Privileged groups such as `IT_Admins` are intentionally excluded from automated standard-user onboarding.

## Onboarding Workflow
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

> Creating accounts disabled initially ensures that partially provisioned identities are not immediately available for authentication.

## Password Handling
Temporary passwords are supplied interactively through Read-Host `-AsSecureString`.

The script is designed to:
- Avoid storing passwords in CSV files or audit logs.
- Prompt for a separate temporary password for each new account.
- Require the password to comply with the domain password policy.
- Enforce `ChangePasswordAtLogon` before the provisioning workflow is considered complete.
- Verify the password-change requirement through the Active Directory `pwdLastSet` attribute.

## Error Handling and Duplicate Prevention
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

> Previously existing accounts are not modified or recreated automatically.

## Execution
<b>Execution host:</b> `MGMT01`   
<b>PowerShell version:</b>  `Windows PowerShell 5.1`   
<b>Required module:</b>  `ActiveDirectory`   
<b>Target domain:</b>  `baron.example.com`   
<b>Default domain controller:</b>  `DC01`   

> The script requires an account with appropriate permissions to create and configure standard users within the designated OUs.

### Preview changes without modifying AD:
```powershell
.\New-ADUserFromCSV.ps1 -CsvPath '.\Samples\NewUsers-Sample.csv' -WhatIf
```
### Execute user onboarding:
```powershell
.\New-ADUserFromCSV.ps1 -CsvPath '.\Samples\NewUsers-Sample.csv'
```

## Audit Logging
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

> Temporary passwords are not included in the audit logs.

## Validation
### A five-user CSV test was executed against `DC01`.

> The execution confirmed that the script's automated verification checks completed successfully, including account enablement, expected group membership and the mandatory password-change requirement.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/New-ADUserFromCSV%20Powershell%20Output.png" width="900"/>

> An audit log was successfully generated.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/New-ADUserFromCSV%20-%20CSV%20Log.png" width="900"/>

> New accounts with correctly assigned OU's and Security Groups were inspected in `Active Directory Users and Computers`.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/New-ADUserFromCSV%20-%20ADUC%20Verification.png" width="900"/>
