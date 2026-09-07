# Template
# Group Policy Configuration
> This section documents the Group Policy Objects implemented within the `baron.example.com` domain to centrally manage workstation security, local administrator access and Windows LAPS.

## Overview
> Group Policy is managed from `DC01` and applied to Active Directory objects based on their Organisational Unit placement.

The Group Policy design provides:

- Centralised security configuration for domain-joined workstations.
- Controlled local administrator membership.
- Automated management of local administrator credentials using Windows LAPS.
- Consistent configuration across domain-joined systems.
- OU-based targeting of computer and user policies.

### Group Policy Management

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Group%20Policy.png" width="900"/>

## Group Policy Design

|GPO|Scope|Purpose|
|---|---|---|
|`Domain-Account-Policy`|`baron.example.com`|Password/lockout security|
|`Workstation-Security-Baseline`|`Workstations`|Endpoint hardening|
|`User-Drive-Mappings`|`Baron Users`|Role-based file access|
|`Workstation-Local-Admins`|`Workstations`|Least privilege|
|`Windows-LAPS`|`Workstations`|Local credential rotation|

Group Policies are linked to the relevant OUs rather than applied indiscriminately across the entire domain.

> Active Directory OU design is documented in [Active Directory Domain Services](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md).

## Domain Account Policy

### Purpose
The `Domain-Account-Policy` GPO defines domain-wide password and account lockout requirements for user accounts in the `baron.example.com` domain.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`baron.example.com` domain root|
|Configuration Type|`Computer Configuration`|
|Security Filtering|`Authenticated Users`|

### Configuration  
|Configuration Area|Policy|
|---|---|
|`Enforce password history`|`10 passwords remembered`|
|`Maximum password age`|`90 days`|
|`Minimum password age`|`1 day`|
|`Password must meet complexity requirements`|`Enabled`|
|`Account lockout duration`|`0 minutes`|
|`Account lockout threshold`|`5 invalid logon attempts`|
|`Allow administrator account lockout`|`Enabled`|
|`Reset account lockout counter after`|`15 minutes`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Domain-Account-Policy%20GPO.png" width="900"/>

### Validation

## Workstation Security Baseline Policy

### Purpose
The `Workstation-Security-Baseline` GPO applies centralised security settings to domain-joined Windows workstations.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`Workstations` OU|
|Configuration Type|`Computer Configuration`|
|Security Filtering|`Authenticated Users`|

### Configuration  
|Configuration Area|Policy|
|---|---|
|`Accounts: Guest account access`|`Disabled`|
|`Interactive Logon: Machine inactivity limit`|`300 seconds`|
|`Firewall state`|`On`|
|`Inbound connections`|`Block`|
|`Outbound connections`|`Allow`|
|`Windows Defender firewall: Protect all network connections`|`Enabled`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Workstation-Security-Baseline%20GPO.png" width="900"/>

### Validation

## User Drive Mapping Policy

### Purpose
The `User-Drive-Mappings` GPO maps `CompanyData` file share. Access to department folders within file share are managed by NTFS permissions.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`Baron Users` OU|
|Configuration Type|`User Configuration`|
|Security Filtering|`Authenticated Users`|

### Configuration  
|Configuration Area|Policy|
|---|---|
|`Letter`|`E`|
|`Location`|`\\FS01\CompanyData`|
|`Reconnect`|`Disabled`|
|`Label as`|`CompanyData`|
|`Use first available`|`Disabled`|
|`Hide/show this drive`|`Show`|
|`Hide/show all drives`|`No change`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/User-Drive-Mapping%20GPO.png" width="900"/>

### Validation


## Workstation Local Administrator Policy

### Purpose
The `Workstation-Local-Admins` GPO centrally controls membership of the local `Administrators` group on domain-joined workstations.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`Workstations` OU|
|Configuration Type|`Computer Configuration`|
|Security Filtering|`Authenticated Users`|

### Configuration  
|Configuration Area|Policy|
|---|---|
|`Action`|`Update`|
|`Group name`|`Administrators (built-in)`|
|`Delete all member users`|`Disabled`|
|`Delete all member groups`|`Disabled`|
|`Add members`|`BARON\IT_Admins`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Workstation-Local-Admins%20GPO.png" width="900"/>

### Validation


## Windows LAPS Policy

### Purpose
The `Windows-LAPS` GPO centrally manages and rotates the local administrator credentials of domain-joined workstations.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`Workstations` OU|
|Configuration Type|`Computer Configuration`|
|Security Filtering|`Authenticated Users`|

### Configuration  
|Configuration Area|Policy|
|---|---|
|`Configure automatic account management`|`Manage a custom admin account`|
|`Automatic account name (or name prefix)`|`LabLaps`|
|`Enable the managed account`|`Enabled`|
|`Randomize the name of the managed account`|`Enabled`|
|`Configure password backup directory`|`Enabled`|
|`Backup directory`|`Active Directory`|
|`Do not allow password expiration time longer than reguired by policy`|`Enabled`|
|`Enable password encryption`|`Enabled`|
|`Password complexity`|`Large letters + small letters + numbers + specials`|
|`Password length`|`14`|
|`Password age (days)`|`30`|
|`Passphrase length (Words)`|`6`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Windows-LAPS%20GPO.png" width="900"/>

### Validation

## Skills Demonstrated
- Create and manage Active Directory Group Policy Objects.
- Design OU-based Group Policy targeting.
- Apply centralised workstation security configuration.
- Manage local administrator membership through Group Policy.
- Configure Windows LAPS using Group Policy.
- Validate applied Group Policy using gpresult.
- Validate local group membership using PowerShell.
- Validate Windows LAPS configuration using PowerShell.

