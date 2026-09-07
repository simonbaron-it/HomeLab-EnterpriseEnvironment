# Group Policy Configuration
> This section documents the Group Policy Objects implemented within the `baron.example.com` domain to centrally manage workstation security, local administrator access and Windows LAPS.

## Overview
> Group Policy is managed from `DC01` and applied to Active Directory objects based on their Organisational Unit placement.

The Group Policy design provides:

- Centralised security configuration for domain-joined workstations.
- Centralised assignment of administrative access to domain-joined workstations.
- Automated management of local administrator credentials using Windows LAPS.
- Consistent configuration across domain-joined systems.
- OU-based targeting of computer and user policies.

### Group Policy Management

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Group%20Policy.png" width="900"/>

## Group Policy Design

|GPO|Linked To|Purpose|
|---|---|---|
|`Domain-Account-Policy`|`baron.example.com`|Password/lockout security|
|`Workstation-Security-Baseline`|`Workstations`|Endpoint hardening|
|`User-Drive-Mappings`|`Baron Users`|Role-based file access|
|`Workstation-Local-Admins`|`Workstations`|Local administrator access|
|`Windows-LAPS`|`Workstations`|Local credential rotation|

GPOs are linked at the narrowest appropriate scope. The domain account policy is linked at the domain root, while workstation and user policies are targeted through the relevant Organisational Units.

> Active Directory OU design is documented in [Active Directory Domain Services](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md).

## Domain Account Policy GPO

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
|`Account lockout duration`|`0 minutes` `(administrator unlock required)`|
|`Account lockout threshold`|`5 invalid logon attempts`|
|`Allow administrator account lockout`|`Enabled`|
|`Reset account lockout counter after`|`15 minutes`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Domain-Account-Policy%20GPO.png" width="900"/>

### Validation
> PowerShell was used on `DC01` to verify the effective domain password and account lockout policy.

<img src="INSERT-SCREENSHOT" width="900"/>

    Get-ADDefaultDomainPasswordPolicy |
    Select-Object ComplexityEnabled,
              PasswordHistoryCount,
              MaxPasswordAge,
              MinPasswordAge,
              LockoutThreshold,
              LockoutDuration,
              LockoutObservationWindow

## Workstation Security Baseline GPO

### Purpose
The `Workstation-Security-Baseline` GPO applies centralised security settings to domain-joined Windows workstations.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`Workstations`|
|Configuration Type|`Computer Configuration`|
|Security Filtering|`Authenticated Users`|

### Configuration  
|Configuration Area|Policy|
|---|---|
|`Accounts: Guest account status`|`Disabled`|
|`Interactive Logon: Machine inactivity limit`|`300 seconds`|
|`Firewall state`|`On`|
|`Inbound connections`|`Block`|
|`Outbound connections`|`Allow`|
|`Windows Defender firewall: Protect all network connections`|`Enabled`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Workstation-Security-Baseline%20GPO.png" width="900"/>

### Validation
    gpresult /r /scope computer
    
    Get-NetFirewallProfile |
    Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction

## User Drive Mapping GPO

### Purpose
The `User-Drive-Mappings` GPO centrally maps the `CompanyData` file share for domain users. Access to departmental folders within the share is controlled separately through NTFS permissions and Active Directory security groups.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`Baron Users`|
|Configuration Type|`User Configuration`|
|Security Filtering|`Authenticated Users`|

### Configuration  
|Configuration Area|Policy|
|---|---|
|`Letter`|`E:`|
|`Location`|`\\FS01\CompanyData`|
|`Reconnect`|`Disabled`|
|`Label as`|`CompanyData`|
|`Use first available`|`Disabled`|
|`Hide/show this drive`|`Show`|
|`Hide/show all drives`|`No change`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/User-Drive-Mapping%20GPO.png" width="900"/>

### Validation
<i>File explorer screenshot</i>

## Workstation Local Administrator GPO

### Purpose
The `Workstation-Local-Admins` GPO ensures the `BARON\IT_Admins` security group is added to the local `Administrators` group on domain-joined workstations, providing centralised administrative access without assigning individual domain accounts directly.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`Workstations`|
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
    Get-LocalGroupMember -Group "Administrators"

## Windows LAPS GPO

### Purpose
The `Windows-LAPS` GPO centrally manages and rotates the local administrator credentials of domain-joined workstations.

### Scope  
| Setting | Value |
|---|---|
|Linked To|`Workstations`|
|Configuration Type|`Computer Configuration`|
|Security Filtering|`Authenticated Users`|

### Configuration  
|Configuration Area|Policy|
|---|---|
|`Configure automatic account management`|`Manage a custom admin account`|
|`Automatic account name (or name prefix)`|`LabLaps`|
|`Enable the managed account`|`Enabled`|
|`Randomise the name of the managed account`|`Enabled`|
|`Configure password backup directory`|`Enabled`|
|`Backup directory`|`Active Directory`|
|`Do not allow password expiration time longer than required by policy`|`Enabled`|
|`Enable password encryption`|`Enabled`|
|`Password complexity`|`Large letters + small letters + numbers + specials`|
|`Password length`|`14`|
|`Password age (days)`|`30`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Windows-LAPS%20GPO.png" width="900"/>

### Validation
    Get-LapsADPassword -Identity CLIENT01 |
    Select-Object ComputerName, Account, PasswordUpdateTime, ExpirationTimestamp

## Validation Summary
Validation confirmed:
- The configured password and account lockout policy is effective across the `baron.example.com` domain.
- `CLIENT01` receives the expected workstation Group Policy Objects.
- Workstation firewall settings are applied through the security baseline GPO.
- The `CompanyData` share is automatically mapped as drive `E:` for domain users.
- `BARON\IT_Admins` is added to the local `Administrators` group on domain workstations.
- Windows LAPS automatically manages and rotates the designated local administrator credentials.
- LAPS credential information is securely backed up to Active Directory.


## Skills Demonstrated
- Create and manage Active Directory Group Policy Objects.
- Design domain-level and OU-based Group Policy targeting.
- Configure domain password and account lockout policies.
- Apply centralised workstation security configuration.
- Deploy file-share mappings through Group Policy Preferences.
- Manage local administrator access through Active Directory security groups.
- Configure Windows LAPS automatic account management and credential rotation.
- Validate local group membership using PowerShell.
- Validate Windows LAPS configuration using PowerShell.

