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

### Validation

## User Drive Mapping Policy

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

### Validation


## Workstation Local Administrator Policy

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

### Validation


## Windows LAPS Policy

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

