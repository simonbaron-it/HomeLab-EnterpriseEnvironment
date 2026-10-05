# Centralised Monitoring and Event Forwarding
> This section documents the implementation of centralised monitoring and logging within the baron.example.com home lab environment.
>
> The solution introduces a dedicated management server, MGMT01, which provides a central location for infrastructure administration, health monitoring, performance monitoring, and event collection.

## Overview
The main objectives of this implementation were to:
- Deploy a dedicated central management server.
- Provide browser-based administration through Windows Admin Center.
- Provide multi-server visibility through Server Manager.
- Centralise Windows event logs using Windows Event Forwarding.
- Collect infrastructure errors and critical events.
- Collect relevant identity and security events.
- Monitor account creation, deletion, modification, and lockout activity.
- Validate monitoring during simulated infrastructure failures.

> PowerShell automation used for infrastructure health checking and event reporting is documented separately in <i>PowerShell Automation.</i>

## Monitoring Infrastructure
The monitoring solution uses `MGMT01` as the central management and logging server.

|Server|Role|Monitoring Function|
|---|---|---|
|`DC01`|`Domain Controller`, `DNS`, `DHCP`|Managed server and WEF source|
|`DC02`|`Domain Controller`, `DNS`, `DHCP`|Managed server and WEF source|
|`FS01`|`File Server`|Managed server and WEF source|
|`CLIENT01`|`Windows Client`|WEF source|
|`MGMT01`|`Management Server`|WAC gateway and Windows Event Collector|

## MGMT01 Deployment
A dedicated Windows Server virtual machine was created to prevent monitoring and management workloads from being hosted on production infrastructure roles such as the domain controllers.

### Virtual Machine Configuration

|Setting|Configuration|
|---|---|
|VM Name|`MGMT01`|
|Operating System|`Windows Server 2025`|
|Hyper-V Gen|`Gen 2`|
|vCPU|`2`|
|Memory|`4GB`|
|OS Disk|`50GB`|
|vSwitch|`LAB-SERVERS`|
|Domain|`baron.example.com`|
|IP Address|`10.10.10.30/24`|
|Default Gateway|`10.10.10.1`|
|DNS|`10.10.10.10`, `10.10.10.11`|

## Windows Admin Centre
Windows Admin Center was installed on MGMT01 to provide browser-based central administration.

|Setting|Value|
|---|---|
|Gateway Server|`MGMT01`|
|FQDN|`MGMT01.baron.example.com`|
|HTTPS Port|`6516`|
|Access URL|`https://MGMT01.baron.example.com:6516`|
|Servers Added|`MGMT01`, `DC01`, `DC02`, `FS01`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Windows%20Admin%20Centre.png" width="900"/>

### Infrastructure Monitoring
Windows Admin Center was used to observe important infrastructure performance counters.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Windows%20Admin%20Centre%20-%20DC01.png" width="900"/>

## Server Manager
Server Manager on `MGMT01` was configured with the primary infrastructure servers: `DC01`, `DC02` & `FS01`

<i>Screenshot: Server Manager All Servers view.</i>

### Health Monitoring

Server Manager was used to monitor:
- Server manageability
- Windows events
- Service health
- Installed roles
- Server availability

<i>Screenshot: All Servers dashboard showing healthy infrastructure.</i>

## Windows Event Forwarding
### Event Collector Configuration
MGMT01 was configured as a Windows Event Collector.

> WinRM was initialised:   
> `winrm qc -q`
>
> Windows Event Collector was configured using:   
> `wecutil qc /q`
> 
> Service status was validated using:   
> `Get-Service WinRM,Wecsvc`

The central destination for collected logs is:   
`Event Viewer`   
→ `Windows Logs`   
→ `Forwarded Events`

<i>Screenshot: Forwarded Events log configuration??</i>

### WEF Forwarder Group
A dedicated Active Directory security group was created to control which computers are authorised to forward events. `DC01`, `DC02`, `FS01` & `CLIENT01` were added as members.

```powershell
New-ADGroup `
    -Name "WEF_Forwarders" `
    -SamAccountName "WEF_Forwarders" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=Baron Security Groups,DC=baron,DC=example,DC=com" `
    -Description "Computers authorised to forward Windows events to MGMT01"

$Computers = "DC01","DC02","FS01","CLIENT01" |
    ForEach-Object { Get-ADComputer $_ }

Add-ADGroupMember `
    -Identity "WEF_Forwarders" `
    -Members $Computers
```

<i>Screenshot: group membership (AD or PowerShell)</i>

### Event Forwarding Group Policy
A new `Infrastructure-Event-Forwarding` Group Policy Object was created.

Policy Configuration:   
> `Computer Configuration`   
> → `Policies`   
> → `Administrative Templates`   
> → `Windows Components`   
> → `Event Forwarding`    
> → `Configure target Subscription Manager`

The GPO was scoped to members of `WEF_Forwarders`

<i>Screenshot: Group Policy configuration for Event Forwarding.</i>

## Event Subscriptions

### Infrastructure Critical and Error Events
A source-initiated subscription was created on `MGMT01`.

|Setting|Value|
|---|---|
|Name|`Infrastructure-Critical-Errors`|
|Type|`Source computer initiated`|
|Source Group|`BARON\WEF_Forwarders`|
|Destination|`Forwarded Events`|
|Logs|`Application, System`|
|Event Levels|`Critical, Error`|
|Delivery|`Minimise Latency`|

<i>Screenshot: Subscription configuration and active event sources.</i>

### Identity and Security Events
A second subscription was created to centralise important identity and security events.

|Setting|Value|
|---|---|
|Name|`Identity-Security-Events`|
|Destination|`Forwarded Events`|
|Delivery|`Minimise Latency`|

The subscription collects selected Security Event IDs:
|Setting|Value|
|---|---|
|`4625`|`Failed logon`|
|`4720`|`User account created`|
|`4725`|`User account disabled`|
|`4726`|`User account deleted`|
|`4728`|`Member added to global security group`|
|`4732`|`Member added to local/domain-local security group`|
|`4738`|`User account changed`|
|`4740`|`User account locked out`|

<i>Screenshot: Identity-Security-Events subscription.</i>

## Security Auditing

### Audit Policy
A dedicated `Infrastructure-Auditing` Group Policy Object was created.

Policy Configuration:   
> `Computer Configuration`   
> → `Policies`   
> → `Windows Settings`   
> → `Security Settings`   
> → `Advanced Audit Policy Configuration`    
> → `Audit Policies`

The following categories were enabled:
> `Account Management`  
> &nbsp;&nbsp;↳ `Audit User Account Management`   
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Success`   
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Failure`   
>     
> &nbsp;&nbsp;↳ `Audit Security Group Management`   
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Success`   
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Failure`   
>
> `Logon/Logoff`    
> &nbsp;&nbsp;↳ `Audit Logon`   
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ `Failure`

<i>Screenshot: Advanced Audit Policy configuration.</i>

## Account Management Events
Account lifecycle activity was tested using a disposable test account.
