# Group Policy Configuration 
> This section documents the Group Policy configuration implemented within my Windows Server home lab.
>
> The objective was to use Group Policy to centrally manage user and computer settings across the Active Directory domain, applying configuration and security controls based on Organisational Unit structure.

## Overview
The policies implemented in this lab were designed to demonstrate practical experience with:

> - Group Policy Objects  
> - OU-based policy targeting  
> - User and computer configuration  
> - Security settings  
> - Password and account policies  
> - Desktop restrictions  
> - Drive mappings  

## Environment
|Component|Configuration|
|---------|-------------|
|`Domain`|`Baron.local`|
|`Domain Controller`|`DC01`|
|`Operating System`|`Windows Server 2022`|
|`Management Tool`|`Group Policy Management Console`|

## Group Policy Design
> The Group Policy structure was designed around the Organisational Units created within Active Directory.

<i>Screenshot of Group Policy Structure</i>

## Group Policy Objects
> The following Group Policy Objects were created within the lab.

|GPO|Type|Applied|Purpose|
|---|----|-------|-------|
|`GPO1`|`User`|`User OU`|`GPO Purpose`|
|`GPO2`|`Computer`|`Laptop OU`|`GPO Purpose`|

### Group Policy Object 1
> GPO1 Purpose
##### Scope
AD OU
##### Configuration
<i> Screenshot of GPMC settings</i>

### Group Policy Object 2
> GPO2 Purpose
##### Scope
AD OU
##### Configuration
<i> Screenshot of GPMC settings</i>

### Group Policy Object 3
> GPO3 Purpose
##### Scope
AD OU
##### Configuration
<i> Screenshot of GPMC settings</i>

GPO's linked to Security groups?

## Validation?
## Security Considerations?
## Skills Demonstrated?
