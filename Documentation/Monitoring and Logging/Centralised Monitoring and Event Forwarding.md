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

> PowerShell automation used for infrastructure health checking and event reporting is documented separately in [PowerShell Infrastructure Automation](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/PowerShell%20Automation/PowerShell%20Infrastructure%20Automation.md).

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

## Windows Admin Center
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

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Server%20Manager%20-%20All%20Servers.png" width="900"/>

### Health Monitoring

Server Manager was used to monitor:
- Server manageability
- Windows events
- Service health
- Installed roles
- Server availability

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Server%20Manager%20-%20Dashboard.png" width="900"/>

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

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/WEF_Forwarders%20Group.png" width="600"/>

### Event Forwarding Group Policy
A new `Infrastructure-Event-Forwarding` Group Policy Object was created.

Policy Configuration:   
> `Computer Configuration`   
> → `Policies`   
> → `Administrative Templates`   
> → `Windows Components`   
> → `Event Forwarding`    
> → `Configure target Subscription Manager`

The GPO was linked to the `baron.example.com` domain root and scoped to members of `WEF_Forwarders`.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Infrastructure%20Event%20Forwarding%20GPO.png" width="900"/>

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

### Identity and Security Events
A second subscription was created to centralise important identity and security events.

|Setting|Value|
|---|---|
|Name|`Identity-Security-Events`|
|Type|`Source computer initiated`|
|Source Group|`BARON\WEF_Forwarders`|
|Destination|`Forwarded Events`|
|Logs|`Security`|
|Delivery|`Minimise Latency`|

The subscription collects selected Security Event IDs:
|Event ID|Event|
|---|---|
|`4625`|`Failed logon`|
|`4720`|`User account created`|
|`4725`|`User account disabled`|
|`4726`|`User account deleted`|
|`4728`|`Member added to global security group`|
|`4732`|`Member added to local/domain-local security group`|
|`4738`|`User account changed`|
|`4740`|`User account locked out`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Event%20Viewer%20Subscriptions.png" width="900"/>

## Security Auditing

### Audit Policy
A dedicated `Infrastructure-Auditing` Group Policy Object was created, linked to the `baron.example.com` domain root and scoped to members of `WEF_Forwarders`.

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

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Audit%20Policy%20GPO.png" width="900"/>

## Account Management Events
Account lifecycle activity monitoring was tested using a disposable `Monitoring Test User` AD account. Forwarded account modification events were queried using PowerShell.

> ### Account Created
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/PowerShell%20Monitoring%20-%20User%20Creation%20.png" width="900"/>

> ### Account Disabled
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/PowerShell%20Monitoring%20-%20User%20Disabled%20.png" width="900"/>

> ### Account Deleted
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/PowerShell%20Monitoring%20-%20User%20Deletion%20.png" width="900"/>

## Account Lockout Events
A disposable standard user account was used to generate a controlled account lockout. Incorrect passwords were deliberately entered from CLIENT01 until the domain lockout policy was triggered.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/PowerShell%20Monitoring%20-%20User%20Locked%20.png" width="900"/>

## Event Forwarding Test
A controlled Application error was generated on FS01:

```powershell
eventcreate /T ERROR /ID 100 /L APPLICATION /SO BaronLab-Monitoring /D "Phase 2 WEF validation event generated on FS01"
```

Forwarded error events were then queried on `MGMT01` using PowerShell.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Monitoring%20-%20FS01.png" width="900"/>

## Infrastructure Failure Test
A controlled domain-controller outage was performed to confirm that infrastructure failures could be identified centrally.

### Procedure
1. Confirmed DC01 and DC02 were healthy.
2. Powered off DC01.
3. Reviewed Server Manager.
4. Reviewed WEF subscription state.
5. Confirmed DC02 remained operational.
6. Restarted DC01.
7. Confirmed AD replication recovered.

> #### Server Manager showing outage

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Monitoring%20-%20DC01%20outage.png" width="900"/>

> #### WEF Subscription state showing DC01 with an older `LastHeartbeatTime` than connected servers

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Monitoring%20-%20DC01%20outage%202.png" width="900"/>

> #### AD replication after DC01 recovery

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Monitoring%20-%20DC01%20outage%203.png" width="900"/>

## Validation Summary
- `MGMT01` provides a dedicated central management and monitoring layer for the lab.
- Windows Admin Center provides browser-based administration and infrastructure performance visibility.
- Server Manager provides centralised visibility of server availability, services, events and installed roles.
- Windows Event Forwarding centralises relevant events from domain-joined infrastructure systems.
- Critical and error events from the `Application` and `System` logs are forwarded to `MGMT01`.
- Selected identity and security events are centrally collected through the `Identity-Security-Events` subscription.
- Active Directory account modification and lockout activity can be identified centrally.
- A controlled application error generated on `FS01` was successfully received by the Windows Event Collector.
- A controlled `DC01` outage was visible through Server Manager and WEF subscription state.
- Active Directory replication was confirmed healthy after `DC01` returned to service.

## Skills Demonstrated
- Deploy a dedicated Windows Server management and monitoring server.
- Configure Windows Admin Center for centralised server administration.
- Use Server Manager for multi-server infrastructure monitoring.
- Configure Windows Event Collector and Windows Event Forwarding.
- Implement source-initiated WEF subscriptions using Group Policy.
- Configure Advanced Audit Policy for identity and security monitoring.
- Monitor Active Directory account lifecycle and lockout events.
- Query centralised Windows events using PowerShell.
- Validate centralised logging using controlled event generation.
- Detect and investigate infrastructure failures using centralised management and logging tools.
