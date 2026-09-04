# Active Directory Domain Services
> This section documents the deployment of Active Directory Domain Services on `DC01`, including the domain configuration, organisational unit structure and security groups used throughout the home lab.

## Domain Controller

|Component|Configuration|
|---|---|
|Server|`DC01`|
|Operating System|`Windows Server 2025`|
|Role|`AD DS` `DNS` `DHCP` `Group Policy`|
|Domain|`Baron.example.com`|
|IP Address|`10.10.10.10`|

## Domain Setup

The Active Directory Domain Services role was installed on `DC01` and the server was promoted as the first domain controller in a new Active Directory forest using: `Baron.example.com`.

The domain provides:

- Centralised user and computer authentication.
- Centralised management of domain identities.
- Organisational Unit-based administration.
- Security group-based access control.
- A foundation for Group Policy deployment.

# Active Directory Users and Computers
Users, organisational units and security groups were configured using `Active Directory Users and Computers` to simulate how identity, computers, departments and access could be managed within a small organisation.

>- DNS and DHCP is documented in <i>[DNS and DHCP configuration]</i>
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
>Security groups were implemented using the AGDLP model to separate user and role membership from resource permissions.

#### Global Security Groups
|Group|Scope|Type|Purpose|
|---|---|---|---|
|`Finance_Users`|`Global`|`Security`|Represents Finance department users for role-based access|
|`HR_Users`|`Global`|`Security`|Represents HR department users for role-based access|
|`IT_Admins`|`Global`|`Security`|Represents privileged IT administrator accounts|
|`IT_Users`|`Global`|`Security`|Represents IT department users for role-based access|
|`Sales_Users`|`Global`|`Security`|Represents Sales department users for role-based access|

#### Domain Local Security Groups
|Group|Scope|Type|Purpose|
|---|---|---|---|
|`Finance_Folder_Management`|`Domain Local`|`Security`|Assigns Modify permissions to: `\\FS01\Finance\Management`|
|`Finance_Folder_RO`|`Domain Local`|`Security`|Assigns Read-only permissions to: `\\FS01\Finance`|
|`Finance_Folder_RW`|`Domain Local`|`Security`|Assigns Modify permissions to: `\\FS01\Finance`|
|`HR_Folder_Management`|`Domain Local`|`Security`|Assigns Modify permissions to: `\\FS01\HR\Management`|
|`HR_Folder_RO`|`Domain Local`|`Security`|Assigns Read-only permissions to: `\\FS01\HR`|
|`HR_Folder_RW`|`Domain Local`|`Security`|Assigns Modify permissions to: `\\FS01\HR`|
|`IT_Folder_RO`|`Domain Local`|`Security`|Assigns Read-only permissions to: `\\FS01\IT`|
|`IT_Folder_RW`|`Domain Local`|`Security`|Assigns Modify permissions to: `\\FS01\IT`|
|`Sales_Folder_RO`|`Domain Local`|`Security`|Assigns Read-only permissions to: `\\FS01\Sales`|
|`Sales_Folder_RW`|`Domain Local`|`Security`|Assigns Modify permissions to: `\\FS01\Sales`|

## Group-Based Access Control


## Skills Demonstrated
- Install and configure Active Directory Domain Services.
- Deploy a new Active Directory forest and domain.
- Configure and manage a Windows Server domain controller.
- Design and implement an organisational unit structure.
- Manage Active Directory users, computers and security groups.
- Apply role-based group membership for access control.
- Use Global and Domain Local security groups to manage resource permissions.
