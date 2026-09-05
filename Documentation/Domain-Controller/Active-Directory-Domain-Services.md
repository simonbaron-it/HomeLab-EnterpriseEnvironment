# Active Directory Domain Services
> This section documents the deployment of Active Directory Domain Services on `DC01`, including the domain configuration, organisational unit structure and security groups used throughout the home lab.

## Domain Controller

|Component|Configuration|
|---|---|
|Server|`DC01`|
|Operating System|`Windows Server 2025`|
|Role|`Active Directory Domain Services`|
|Additional Services|`DNS` `DHCP`|
|Domain|`baron.example.com`|
|IP Address|`10.10.10.10`|

## Domain Setup

The Active Directory Domain Services role was installed on `DC01` and the server was promoted as the first domain controller in a new Active Directory forest using: `baron.example.com`.

The domain provides:

- Centralised user and computer authentication.
- Centralised management of domain identities.
- Organisational Unit-based administration.
- Security group-based access control.
- A foundation for Group Policy deployment.

# Active Directory Users and Computers
Users, organisational units and security groups were configured using `Active Directory Users and Computers` to simulate how identity, computers, departments and access could be managed within a small organisation.

>- DNS and DHCP are documented in <i>[DNS and DHCP configuration]</i>
>- Group Policy is documented in <i>[Group Policy Configuration]</i>
## Organisational Unit Design
>Organisational Units were created to logically separate users, workstations, servers and administrative objects.

|OU|Purpose|
|---|---|
|`Baron Administrator Accounts`|Stores privileged administrative user accounts|
|`Baron Computers`|Parent OU for domain-joined client devices|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Disabled Computers`|Stores disabled domain-joined client devices|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Workstations`|Stores active domain-joined client devices and provides a target for workstation GPOs|
|`Baron Security Groups`|Parent OU for security groups used for role membership and resource access|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Resource Groups`|Stores domain local security groups assigned permissions to resources|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Role Groups`|Stores global security groups representing user roles and departments|
|`Baron Servers`|Stores domain-joined Windows servers and provides a target for server-specific GPOs|
|`Baron Users`|Parent OU for standard domain user accounts|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Disabled Users`|Stores disabled domain user accounts|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Finance Users`|Stores Finance department domain user accounts|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `HR Users`|Stores HR department domain user accounts|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `IT Users`|Stores IT department domain user accounts|
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Sales Users`|Stores Sales department domain user accounts|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Active%20Directory.png" width="900"/>

## Security Groups
> Security groups were implemented using the AGDLP model to separate user and role membership from resource permissions.

### Global Security Groups
|Group|Scope|Type|Purpose|
|---|---|---|---|
|`Finance_Managers`|`Global`|`Security`|Represents Finance department managers for role-based access|
|`Finance_Users`|`Global`|`Security`|Represents Finance department users for role-based access|
|`HR_Managers`|`Global`|`Security`|Represents HR department managers for role-based access|
|`HR_Users`|`Global`|`Security`|Represents HR department users for role-based access|
|`IT_Admins`|`Global`|`Security`|Represents privileged IT administrator accounts|
|`IT_Users`|`Global`|`Security`|Represents IT department users for role-based access|
|`Sales_Users`|`Global`|`Security`|Represents Sales department users for role-based access|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Active%20Directory%20-%20Global%20Groups.png" width="900"/>

### Domain Local Security Groups
|Group|Scope|Type|Purpose|
|---|---|---|---|
|`Finance_Folder_Management`|`Domain Local`|`Security`|Used to grant Modify access to: `\\FS01\Finance\Management`|
|`Finance_Folder_RO`|`Domain Local`|`Security`|Used to grant Read-only access to: `\\FS01\Finance`|
|`Finance_Folder_RW`|`Domain Local`|`Security`|Used to grant Modify access to: `\\FS01\Finance`|
|`HR_Folder_Management`|`Domain Local`|`Security`|Used to grant Modify access to: `\\FS01\HR\Management`|
|`HR_Folder_RO`|`Domain Local`|`Security`|Used to grant Read-only access to: `\\FS01\HR`|
|`HR_Folder_RW`|`Domain Local`|`Security`|Used to grant Modify access to: `\\FS01\HR`|
|`IT_Folder_RO`|`Domain Local`|`Security`|Used to grant Read-only access to: `\\FS01\IT`|
|`IT_Folder_RW`|`Domain Local`|`Security`|Used to grant Modify access to: `\\FS01\IT`|
|`Public_Folder_RO`|`Domain Local`|`Security`|Used to grant Read & Execute access to: `\\FS01\Public`|
|`Sales_Folder_RO`|`Domain Local`|`Security`|Used to grant Read-only access to: `\\FS01\Sales`|
|`Sales_Folder_RW`|`Domain Local`|`Security`|Used to grant Modify access to: `\\FS01\Sales`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Active%20Directory%20-%20Domain%20Local%20Groups.png" width="900"/>

## Group-Based Access Control
The AGDLP model is implemented where applicable. User accounts are assigned to role-based Global security groups, which are nested within Domain Local resource groups. Permissions are then assigned to the Domain Local groups rather than directly to individual users.

`Account`  
&nbsp;&nbsp;&nbsp;↳`Global Security Group`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳`Domain Local Security Group`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳`Permission`  

Example:  
`Sarah Jones`  
&nbsp;&nbsp;&nbsp;↳`Finance_Users`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳`Finance_Folder_RW`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳Modify access to `\\FS01\Finance`

>File-share permissions and NTFS access control are documented separately in <i>File Services</i>.

### AGDLP Validation
> PowerShell was used to validate the above example's AGDLP model implementation.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/AGDLP%20Validation.png" width="900"/>

## Skills Demonstrated
- Install and configure Active Directory Domain Services.
- Deploy a new Active Directory forest and domain.
- Configure and manage a Windows Server domain controller.
- Design and implement an organisational unit structure.
- Manage Active Directory users, computers and security groups.
- Apply role-based group membership for access control.
- Use Global and Domain Local security groups to manage resource permissions.
