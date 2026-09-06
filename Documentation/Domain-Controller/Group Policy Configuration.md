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

### Group Policy Design

|GPO|Linked To|Purpose|
|---|---|---|
|`Domain-Account-Policy`|`baron.example.com`|Password/lockout security|
|`Workstation-Security-Baseline`|`Workstations`|Endpoint hardening|
|`User-Drive-Mappings`|`Baron Users`|Role-based file access|
|`Workstation-Local-Admins`|`Workstations`|Least privilege|
|`Windows-LAPS`|`Workstations`|Local credential rotation|

Group Policies are linked to the relevant OUs rather than applied indiscriminately across the entire domain.

> Active Directory OU design is documented in [Active Directory Domain Services](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md).

## Domain Account Policy

Purpose  
Scope  
Configuration  
Security rationale  
Testing  
Result  

> A domain account GPO was created to apply consistent security settings to user accounts when logged into domain-joined Windows client devices.

|Configuration Area|Policy|
|---|---|
|`<AREA>`|`<SETTING>`|
|`<AREA>`|`<SETTING>`|
|`<AREA>`|`<SETTING>`|
|`<AREA>`|`<SETTING>`|



## Workstation Security Baseline Policy

Purpose  
Scope  
Configuration  
Security rationale  
Testing  
Result 



## User Drive Mapping Policy

Purpose  
Scope  
Configuration  
Security rationale  
Testing  
Result 

> Group Policy was used to centrally control membership of the local `Administrators` group on domain-joined workstations.

|Configuration|Value|
|---|---|
|GPO|`<GPO-NAME>`|
|Target OU|`Workstations`|
|Local Group|`Administrators`|
|Authorised Domain Group|`<GROUP-NAME>`|

Administrative access is granted through an Active Directory security group rather than by manually assigning individual domain accounts to local administrator groups.

text
Administrative Account
        │
        ▼
AD Security Group
        │
        ▼
Local Administrators Group
        │
        ▼
Domain Workstation

## Workstation Local Administrator Policy

## Windows LAPS Policy

## GPO Links and Inheritance
## Configuration Validation
## Validation Confirmed
## Skills Demonstrated
- Create and manage Active Directory Group Policy Objects.
- Design OU-based Group Policy targeting.
- Apply centralised workstation security configuration.
- Manage local administrator membership through Group Policy.
- Configure Windows LAPS using Group Policy.
- Validate applied Group Policy using gpresult.
- Validate local group membership using PowerShell.
- Validate Windows LAPS configuration using PowerShell.

