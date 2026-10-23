# Centralised Event Reporting
**Script:** `CentralisedEventReport.ps1`

## Purpose
Developed a PowerShell script to automate reporting from the centrally collected Windows events within the `baron.example.com` home lab.

The script runs locally on `MGMT01` and queries the existing `ForwardedEvents` log. It replaces repetitive manual event-log searches with a single reporting workflow that identifies relevant infrastructure errors and identity/security activity, displays a summary in PowerShell, and exports detailed CSV and readable HTML reports.

The automation provides:
- Time-based event retrieval from the central Windows Event Collector.
- Classification of selected identity/security events and infrastructure Critical/Error events.
- Extraction of source computer, original log channel, account-related fields and event messages where available.
- Structured event counts and summaries by category and event ID.
- Timestamped detailed CSV, summary CSV and HTML reports.
- Error handling for empty reporting windows, inaccessible logs and event-query limits.

> The script is read-only with respect to Active Directory, source event logs and WEF configuration. It creates report files locally on `MGMT01` but does not modify the events or subscriptions.

## Execution Environment

|Component|Configuration|
|---|---|
|Execution Server|`MGMT01`|
|PowerShell Version|`Windows PowerShell 5.1`|
|Target Domain|`baron.example.com`|
|Event Collector|`MGMT01` (`10.10.10.30`)|
|Source Event Log|`ForwardedEvents`|
|Event Forwarding Sources|`DC01`, `DC02`, `FS01`, `CLIENT01`|
|Required Access|Permission to read the `ForwardedEvents` log and write to the report directory|
|Default Report Directory|`C:\LabAutomation\Output\EventReports`|

## Windows Event Forwarding Integration
The script uses the Windows Event Forwarding (WEF) infrastructure implemented in the [Centralised Monitoring and Event Forwarding](../Monitoring%20and%20Logging/Centralised%20Monitoring%20and%20Event%20Forwarding.md) section of the lab.

The existing source-initiated subscriptions forward selected events to `MGMT01`:

|WEF Subscription|Source Logs|Forwarded Events|
|---|---|---|
|`Infrastructure-Critical-Errors`|`Application`, `System`|Critical and Error events|
|`Identity-Security-Events`|`Security`|Selected account, authentication and security-group events|

## Identity and Security Event ID's

|Event ID|Event Description|
|---|---|
|`4625`|Failed logon|
|`4720`|User account created|
|`4725`|User account disabled|
|`4726`|User account deleted|
|`4728`|Member added to global security group|
|`4732`|Member added to local/domain-local security group|
|`4738`|User account changed|
|`4740`|User account locked out|

> The report only contains events that were audited, forwarded, retained and matched by the selected time window and event filters. An empty report does not prove that no activity occurred.

## Reporting Workflow
1. Pre-flight validation
- Confirm the script is running on `MGMT01`.
- Verify access to the `ForwardedEvents` log.
- Check the `Wecsvc` (Windows Event Collector) service and warn if it is not running.

2. Event retrieval
- Calculate the start and end of the reporting window using `-Hours`.
- Query the log using `Get-WinEvent -FilterHashtable`.
- Limit retrieved records using `-MaxEvents` and warn if the limit is reached.

3. Event classification
- Identify the configured Security event IDs as `Identity/Security`.
- Classify Critical/Error events originating from the `Application` or `System` channel as `Infrastructure`.
- Exclude events that do not match the reporting criteria.

4. Event detail extraction
- Parse available event XML to retrieve the original log channel and named event fields.
- Capture source computer, Event ID, severity, provider, target account, actor, client IP and message where available.

5. CSV reporting
- Export selected events to a detailed CSV.
- Export event totals by reporting category to a separate summary CSV.

6. HTML reporting
- Generate a browser-readable report showing the reporting window, summary counts and recent matching events.
- HTML-encode event text to prevent it being interpreted as page markup.

7. Output verification
- Confirm that the three expected report files exist and contain data.
- Display their saved paths in PowerShell.

## Event Retrieval and Filtering
The script queries `ForwardedEvents` using `Get-WinEvent`, with configurable parameters:

|Parameter|Default|Purpose|
|---|---|---|
|`-Hours`|`24`|Reporting window in hours (1–720)|
|`-MaxEvents`|`5000`|Maximum raw forwarded records to retrieve (1–100000)|
|`-HtmlLimit`|`200`, `System`|Maximum matching events displayed in HTML (1–2000)|
|`-OutputFolder`|`C:\LabAutomation\Output\EventReports`|Location of generated report files|

The script categorises matching events as follows:

|Category|Selection Criteria|
|---|---|
|`Identity/Security`|Configured Security event IDs from the `Security` channel or `Microsoft-Windows-Security-Auditing` provider|
|`Infrastructure`|Critical (1) or Error (2) events from the `Application` or `System` channel|

> The original log channel and selected account-related fields are extracted from event XML where available. Some events do not contain all fields, so the corresponding report columns may be blank.

## CSV Reporting
The script exports two timestamped CSV files.

**1. Detailed Event Report:** `CentralisedEvents-YYYYMMDD-HHMMSS-fff.csv`

Each selected event contains:

|Field|Description|
|---|---|
|`TimeCreated`|Time the event occurred|
|`SourceComputer`|Computer associated with the event|
|`SourceLog`|Original source channel, when available|
|`Category`|`Identity/Security` or `Infrastructure`|
|`EventID`|Windows Event ID|
|`EventName`|Readable event description|
|`Level`|Event severity|
|`TargetAccount`|Affected account, where present|
|`Actor`|Account responsible for the action, where present|
|`ClientIP`|Client IP address, where present|
|`Provider`|Event provider|
|`RecordId`|Event record identifier|
|`Message`|Normalised event message|

**2. Event Summary Report:** `EventSummary-YYYYMMDD-HHMMSS-fff.csv`

Contains event counts for `Identity/Security`, `Infrastructure` and `Total relevant`.

> If no matching events are found, the script still generates a header-only detailed CSV and a summary showing zero events.

## HTML Reporting
The script generates a timestamped HTML file: `CentralisedEvents-YYYYMMDD-HHMMSS-fff.html`

The report includes:
- Reporting period and collector information.
- Total forwarded records read and relevant event counts.
- A category summary table.
- A table of up to `-HtmlLimit` most recent matching events.
- A warning when `-MaxEvents` is reached and older events may be omitted.

> The complete set of selected events, up to the query limit, remains available in the detailed CSV. Event text is HTML-encoded before being inserted into the report.

### Output Structure

```Plain Text
C:\LabAutomation\Output\EventReports\
├── CentralisedEvents-YYYYMMDD-HHMMSS-fff.csv
├── CentralisedEvents-YYYYMMDD-HHMMSS-fff.html
└── EventSummary-YYYYMMDD-HHMMSS-fff.csv
```

## Security, Error Handling and Limitations
The script includes safeguards and clear reporting limitations:
- <b>Execution restriction:</b> Designed to run locally on `MGMT01` rather than query an unintended local event log.
- <b>Access validation:</b> Stops with an error if `ForwardedEvents` cannot be accessed; insufficient permissions are not treated as an empty log.
- <b>Collector service warning:</b> Warns if `Wecsvc` is not running, although previously collected events may remain readable.
- <b>Empty-window handling:</b> Continues gracefully when no events match the reporting window.
- <b>Event-query limits:</b> Warns when `-MaxEvents` is reached; counts may not represent all events in the requested period.
- <b>XML handling:</b> Continues processing if individual event XML fields cannot be extracted.
- <b>Report verification:</b> Checks for missing or empty CSV/HTML output files.
- <b>Sensitive data:</b> Reports can include usernames, IP addresses and security-event messages and must be stored with appropriate access controls.

> The script reports previously forwarded events; it does not perform continuous monitoring, send alerts, verify that every source is currently forwarding, or replace the `InfrastructureHealthCheck.ps1` script.

## Execution

### Generate the default 24-hour report
```powershell
.\CentralisedEventReport.ps1 -Hours 24
```

### Report on the last hour
```powershell
.\CentralisedEventReport.ps1 -Hours 1
```

### Generate a seven-day report with a larger event limit
```powershell
.\CentralisedEventReport.ps1 -Hours 168 -MaxEvents 10000
```

### Increase the number of events shown in the HTML report
```powershell
.\CentralisedEventReport.ps1 -Hours 24 -HtmlLimit 500
```

## Validation
1. Generate a controlled Application error on `FS01`.
2. Create/disable a disposable AD account to generate identity events.
3. Run: `.\CentralisedEventReport.ps1 -Hours 1`
4. Confirm the report contains the expected source computer and event IDs.
5. Check any CSV/HTML exports for completeness and readability.

### PowerShell Output

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/CentralisedEventReport%20PowerShell%20Output.png" width="900"/>

### Directory output

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/CentralisedEventReport%20Directory%20Output.png" width="900"/>

### HTML Output

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/CentralisedEventReport%20HTML%20Output.png" width="900"/>

