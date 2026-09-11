# File Services and NTFS Access Control

> This section documents the Windows File Services configuration implemented on `FS01`, including storage configuration, SMB file sharing, NTFS permissions and Active Directory group-based access control.

## Overview

> `FS01` provides centralised file storage for domain users within the `baron.example.com` environment.
>
> File access is controlled using Active Directory security groups and the AGDLP model. Users are assigned to role-based Global groups, which are nested within Domain Local resource groups. NTFS permissions are then assigned to the Domain Local groups rather than directly to individual user accounts.
>
> Active Directory security groups used in AGDLP design are documented in [Active Directory Domain Services](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md).

### Server Configuration

|Component|Configuration|
|---|---|
|Server|`FS01`|
|Operating System|`Windows Server 2025`|
|Role|`File Server`|
|IP Address|`10.10.10.20`|
|Domain|`baron.example.com`|
|System Disk|`50GB`|
|Data Disk|`20GB`|

### Storage Configuration

A dedicated virtual disk was provisioned for shared organisational data, separating file storage from the operating system volume.

|Volume|Size|Purpose|
|---|---|---|
|`C:`|`50GB`|Operating system|
|`E:`|`20GB`|Shared organisational data|

> Disk Management showing the dedicated `20GB` data volume used for organisational file storage.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/FS01%20Disk%20Management.png" width="900"/>

## File Share Structure
A central `CompanyData` folder was created on the dedicated data volume and organised into departmental folders. This structure provides centralised storage while allowing access to individual folders to be controlled independently through NTFS permissions.

```text
E:\CompanyData
│
├── Finance
│   └── Management
│
├── HR
│   └── Management
│
├── IT
│
├── Sales
│
└── Public
```

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/FS01%20File%20Structure.png" width="400"/>

## SMB Share Configuration
The `CompanyData` folder was published as an SMB share to allow domain users to access organisational data across the network.

|Setting|Configuration|
|---|---|
|Share Name|`CompanyData`|
|Local Path|`E:\CompanyData`|
|UNC Path|`\\FS01\CompanyData`|

### Share Permissions
SMB share permissions control access to the `CompanyData` share itself, while granular departmental access is enforced through NTFS permissions.

|Principal|Share Permission|
|---|---|
|`NT AUTHORITY\Authenticated Users`|`Change`|
|`BUILTIN\Administrators`|`Full`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/SMB%20Permissions.png" width="900"/>

## NTFS Permission Design
NTFS permissions are assigned to Domain Local resource groups rather than directly to individual users.

|Folder|Security Group|NTFS Permission|
|---|---|---|
|`E:\CompanyData\Finance`|`Finance_Folder_RO`|`Read & Execute`|
|`E:\CompanyData\Finance`|`Finance_Folder_RW`|`Modify`|
|`E:\CompanyData\Finance\Management`|`Finance_Folder_Management`|`Modify`|
|`E:\CompanyData\HR`|`HR_Folder_RO`|`Read & Execute`|
|`E:\CompanyData\HR`|`HR_Folder_RW`|`Modify`|
|`E:\CompanyData\HR\Management`|`HR_Folder_Management`|`Modify`|
|`E:\CompanyData\IT`|`IT_Folder_RO`|`Read & Execute`|
|`E:\CompanyData\IT`|`IT_Folder_RW`|`Modify`|
|`E:\CompanyData\Sales`|`Sales_Folder_RO`|`Read & Execute`|
|`E:\CompanyData\Sales`|`Sales_Folder_RW`|`Modify`|
|`E:\CompanyData\Public`|`Public_Folder_RO`|`Read & Execute`|

### Permission Inheritance
NTFS inheritance is used throughout the departmental folder structure where appropriate. Inheritance was disabled on restricted management folders and inherited departmental permissions were removed, allowing access to be assigned explicitly to authorised management groups.

|Folder|Inheritance|Purpose|
|---|---|---|
|`E:\CompanyData\Finance`|`Enabled`|Departmental permissions inherited by standard child objects|
|`E:\CompanyData\Finance\Management`|`Disabled`|Explicit permissions restrict access to authorised Finance management groups|
|`E:\CompanyData\HR`|`Enabled`|Departmental permissions inherited by standard child objects|
|`E:\CompanyData\HR\Management`|`Disabled`|Explicit permissions restrict access to authorised HR management groups|

> Department managers are also members of their corresponding departmental user group, providing normal departmental access in addition to access to restricted management resources.

## AGDLP Access Model
The AGDLP model separates user role membership from resource permissions. This approach allows permissions to be managed through Active Directory groups rather than assigning access directly to individual user accounts.

### Department Access Model

|Role Group|Resource Group|Resource|Access|
|---|---|---|---|
|`Finance_Users`|`Finance_Folder_RW`|`\\FS01\CompanyData\Finance`|`Modify`|
|`Finance_Managers`|`Finance_Folder_Management`|`\\FS01\CompanyData\Finance\Management`|`Modify`|
|`HR_Users`|`HR_Folder_RW`|`\\FS01\CompanyData\HR`|`Modify`|
|`HR_Managers`|`HR_Folder_Management`|`\\FS01\CompanyData\HR\Management`|`Modify`|
|`IT_Users`|`IT_Folder_RW`|`\\FS01\CompanyData\IT`|`Modify`|
|`Sales_Users`|`Sales_Folder_RW`|`\\FS01\CompanyData\Sales`|`Modify`|
|`Finance_Users`, `HR_Users`, `IT_Users`, `Sales_Users`|`Public_Folder_RO`|`\\FS01\CompanyData\Public`|`Read & Execute`|

`Account`  
&nbsp;&nbsp;&nbsp;↳`Global Security Group`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳`Domain Local Security Group`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳`Permission`  

Example:  
`Sarah Jones`  
&nbsp;&nbsp;&nbsp;↳`Finance_Users`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳`Finance_Folder_RW`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳Modify access to `\\FS01\CompanyData\Finance`

## Configuration Validation
> `CLIENT01` was logged into by the above Finance user account `Sarah Jones`, to verify NTFS permissions.

#### Modify access to `\\FS01\CompanyData\Finance`
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/NTFS%20Finance%20modify%20access.png" width="800"/>


#### Read & Execute access to `\\FS01\CompanyData\Public`
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/NTFS%20Public%20read%20access.png" width="800"/>


#### Denied access to `\\FS01\CompanyData\Finance\Management`
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/NTFS%20deny%20access%20Management.png" width="600"/>

#### Denied access to `\\FS01\CompanyData\HR`
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/NTFS%20deny%20access%20HR.png" width="600"/>


#### Denied access to `\\FS01\CompanyData\IT`
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/NTFS%20deny%20access%20IT.png" width="600"/>


#### Denied access to `\\FS01\CompanyData\Sales`
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/NTFS%20deny%20access%20Sales.png" width="600"/>

### Validation Summary
Validation confirmed:
- `FS01` hosts the `CompanyData` SMB share on a dedicated data volume.
- SMB share permissions provide network access to the shared resource.
- Departmental access is controlled using NTFS permissions assigned to Domain Local security groups.
- Global role groups are nested within the appropriate Domain Local resource groups using AGDLP.
- Authorised users can access and modify resources appropriate to their role.
- Users without the required group membership are denied access to restricted resources.
- Management folders apply additional access restrictions for authorised management groups.

## Skills Demonstrated

- Install and configure Windows Server File Services.
- Provision dedicated storage for shared organisational data.
- Create and configure SMB file shares.
- Design structured departmental file storage.
- Configure SMB share permissions.
- Configure NTFS file and folder permissions.
- Manage NTFS permission inheritance.
- Implement AGDLP-based access control.
- Apply group-based least-privilege access to shared resources.
- Separate SMB share permissions from NTFS resource permissions.
- Validate SMB and NTFS configuration using PowerShell.
- Test authorised and unauthorised resource access.
