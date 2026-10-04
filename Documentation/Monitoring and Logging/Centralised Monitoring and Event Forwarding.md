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
Server Manager on `MGMT01` was configured with the primary infrastructure servers:
- DC01
- DC02
- FS01
