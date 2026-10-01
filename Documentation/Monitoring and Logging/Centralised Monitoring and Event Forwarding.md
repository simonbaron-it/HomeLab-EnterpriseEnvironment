# Centralised Monitoring and Event Forwarding
> This section documents the Phase 2 monitoring and logging implementation used to centralise Windows event data, monitor core infrastructure health and improve troubleshooting across the `baron.example.com` environment.

## Overview
The implementation covers:
- Centralised collection of relevant Windows Event Logs from infrastructure servers.
- Monitoring of `DC01`, `DC02` and `FS01`.
- Visibility of Active Directory, DNS, DHCP, File Services and operating system events.
- Validation using known test events and controlled infrastructure failures.

> PowerShell automation used for infrastructure health checking and event reporting is documented separately in <i>PowerShell Automation.</i>
