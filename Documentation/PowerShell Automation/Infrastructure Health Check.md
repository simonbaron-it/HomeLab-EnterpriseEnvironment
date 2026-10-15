# Infrastructure Health Check
**Script:** `InfrastructureHealthCheck.ps1`

## Purpose
Developed a PowerShell script to automate routine infrastructure health checks across `DC01`, `DC02`, `FS01` and `MGMT01`.

The script runs centrally from `MGMT01`, replacing multiple manual administrative checks with a single execution. It evaluates key infrastructure components, reports their health status and exports the results for troubleshooting and historical reference.

## Checks Performed
- <b>Connectivity:</b> Tests WinRM management connectivity to each server using TCP port 5985.
- <b>Windows Services:</b> Checks critical services including AD DS, DNS, DHCP, Netlogon, Kerberos, SMB and Windows Event Collector.
- <b>DNS:</b> Validates internal hostname resolution and expected IP addresses against both domain controllers.
- <b>Active Directory:</b> Checks replication health, SYSVOL and NETLOGON accessibility, FSMO role ownership and DC diagnostics where available.
- <b>DHCP:</b> Checks the DC01-DC02-Failover relationship, including its operational state and load-balancing mode.
- <b>File Services:</b> Verifies access to \\FS01\CompanyData.
- <b>Storage:</b> Checks available disk space across the servers, using the following thresholds:
    - <b>PASS:</b> 20% or more free.
    - <b>WARN:</b> 10% to less than 20% free.
    - <b>FAIL:</b> Less than 10% free.

## Execution
The script is executed from `MGMT01` using Windows PowerShell 5.1, with the required Active Directory/DHCP management modules and administrative permissions.

```powershell
.\InfrastructureHealthCheck.ps1
```

### Output 
Results are displayed in the PowerShell console as checks complete, allowing the administrator to monitor progress without waiting for the entire script to finish.

Each result includes:
- <b>Category:</b> Infrastructure component being checked.
- <b>Target:</b> Server or service being assessed.
- <b>Check:</b> Specific test performed.
- <b>Status:</b> PASS, WARN or FAIL.
- <b>Detail:</b> Additional diagnostic information or error messages.
- At completion, the script displays a summary of the number of PASS, WARN and FAIL results.
- A timestamped CSV report is also generated at:
    - `C:\LabAutomation\Output\InfrastructureHealth-YYYYMMDD-HHMMSS.csv`

## Error Handling and Resilience

During initial testing, the script experienced significant delays when `DC01` was powered off because multiple commands attempted to contact the unavailable server.

The script was subsequently improved to:
- Perform an initial management-connectivity check with a short TCP connection timeout.
- Avoid repeatedly attempting remote checks against servers whose WinRM endpoints are unreachable.
- Use try/catch error handling to record failures without terminating the entire script.
- Display results progressively to help identify slow or unresponsive checks.
- Defer potentially lengthy domain-controller diagnostics during a known DC outage.
- Continue checking the remaining infrastructure when an individual server becomes unavailable.

## Validation
> The script is tested under both normal and degraded infrastructure conditions.

### Normal-State Validation
1. Ensure `DC01`, `DC02`, `FS01` and `MGMT01` are online.
2. Execute the script from `MGMT01`.
3. Review connectivity, services, DNS, AD replication, DHCP failover, file-sharing and storage results.
4. Investigate any unexpected warnings or failures.
5. Confirm that a timestamped CSV report is generated.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/InfrastructureHealthCheck%20Output%20-%20Healthy.png" width="700"/>

### Failure-State Validation
1. Shut down DC01 through Hyper-V while keeping DC02 operational.
2. Execute the script again from MGMT01.
3. Confirm that the unavailable server is detected and dependent checks are handled without repeatedly waiting for connection timeouts.
4. Verify that checks against the remaining available infrastructure continue.
5. Restart DC01, confirm AD replication and DHCP failover recovery, and rerun the script.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/InfrastructureHealthCheck%20Output%20-%20DC01%20Failure.png" width="700"/>

### CSV File Validation

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/InfrastructureHealthCheck%20Output%20-%20CSV.png" width="900"/>
