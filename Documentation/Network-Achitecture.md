## Network Architecture
This document describes the network architecture of the Enterprise Environment Home Lab. The environment simulates a small business network using virtual machines hosted on VMWare Workstation Pro. 

### Virtual Network Configuration
|Component|Configuration|
|---------|-------------|
|Subnet|192.168.162.0/24|
|Gateway|192.168.162.1|
|DNS Server|192.168.162.10|
|DHCP Server|192.168.162.10|
|DHCP Range|192.168.162.100 - .200|



### Logical Topology

<img src="https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Images/Network%20Diagram.png" width="800" height="800"/>

|Device|Role|IP Address|Services|
|-------|----|----------|--------|
|Physical Host|Virtualisation|NAT|VMWare Workstation Pro|
|Windows Server 2022 VM|Domain Controller|192.168.162.10|Active Directory, DNS, DHCP|
|Windows Server 2022 VM|File Server|192.168.162.20|Network File Shares|
|Windows 11 VM|Domain User Workstation|DHCP|Domain Testing/Validation|
