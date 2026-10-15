# Centralised Event Reporting
**Script:** `Get-CentralisedEventReport.ps1`

## Purpose
Query the `ForwardedEvents` log on `MGMT01` and generate an operational summary of infrastructure and identity/security activity.

## Event Sources
- `Infrastructure-Critical-Errors`: Critical/Error events from Application and System logs.
- `Identity-Security-Events`: selected security events, including `4625`, `4720`, `4725`, `4726` and `4740`.

## Execution
```powershell
.\Get-CentralisedEventReport.ps1 -Hours 24
```

## Validation
1. Generate a controlled Application error on `FS01`.
2. Confirm the event appears in `MGMT01`'s `ForwardedEvents` log.
3. Create/disable a disposable AD account to generate identity events.
4. Confirm the report contains the expected source computer and event IDs.
5. Check any CSV/HTML exports for completeness and readability.

**Output location:** `[INSERT PATH]`  
**Observed results:** `[INSERT RESULTS]`

<i>Add: screenshot of report output / HTML report</i>

## WEF Integration
## Event Filtering
## CSV Reporting
## HTML Reporting
