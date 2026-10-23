#Requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateRange(1,720)]
    [int]$Hours = 24,

    [ValidateRange(1,100000)]
    [int]$MaxEvents = 5000,

    [ValidateRange(1,2000)]
    [int]$HtmlLimit = 200,

    [ValidateNotNullOrEmpty()]
    [string]$OutputFolder = 'C:\LabAutomation\Output\EventReports'
)

$ErrorActionPreference = 'Stop'

# ================================================
# SECTION 1 - CONFIGURATION
# ================================================
$LogName = 'ForwardedEvents'
$EndTime = Get-Date
$StartTime = $EndTime.AddHours(-$Hours)
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'

$CsvPath = Join-Path $OutputFolder "CentralisedEvents-$Timestamp.csv"
$SummaryPath = Join-Path $OutputFolder "EventSummary-$Timestamp.csv"
$HtmlPath = Join-Path $OutputFolder "CentralisedEvents-$Timestamp.html"

$SecurityEventNames = @{
    4625 = 'Failed logon'
    4720 = 'User account created'
    4725 = 'User account disabled'
    4726 = 'User account deleted'
    4728 = 'Member added to global security group'
    4732 = 'Member added to local/domain-local security group'
    4738 = 'User account changed'
    4740 = 'User account locked out'
}

# ================================================
# SECTION 2 - REUSABLE HELPER FUNCTIONS
# ================================================
function ConvertTo-SafeHtml {
    param([AllowNull()][object]$Value)
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Get-ForwardedEventDetails {
    param([Parameter(Mandatory = $true)]$Event)

    $Channel = 'Unknown'
    $Fields = @{}

    try {
        $Xml = [xml]$Event.ToXml()
        $ChannelNode = $Xml.SelectSingleNode("//*[local-name()='System']/*[local-name()='Channel']")
        if ($ChannelNode -and $ChannelNode.InnerText) {
            $Channel = $ChannelNode.InnerText
        }

        $DataNodes = $Xml.SelectNodes("//*[local-name()='EventData']/*[local-name()='Data']")
        foreach ($Node in $DataNodes) {
            $Name = $Node.GetAttribute('Name')
            if (-not [string]::IsNullOrWhiteSpace($Name)) {
                $Fields[$Name] = $Node.InnerText
            }
        }
    }
    catch {
        Write-Verbose "XML could not be parsed for record $($Event.RecordId): $($_.Exception.Message)"
    }

    [PSCustomObject]@{
        SourceLog     = $Channel
        TargetAccount = [string]$Fields['TargetUserName']
        Actor         = [string]$Fields['SubjectUserName']
        ClientIP      = [string]$Fields['IpAddress']
    }
}

# ================================================
# SECTION 3 - PRE-FLIGHT CHECKS
# ================================================
if ($env:COMPUTERNAME -ne 'MGMT01') {
    throw 'This lab report script is designed to run locally on MGMT01.'
}

try {
    $LogInfo = Get-WinEvent -ListLog $LogName -ErrorAction Stop
}
catch {
    throw "Cannot access the $LogName log. Open PowerShell with sufficient permissions on MGMT01. $($_.Exception.Message)"
}

if (-not $LogInfo.IsEnabled) {
    Write-Warning "The $LogName log is disabled. The report may contain no recent events."
}

$Collector = Get-Service -Name Wecsvc -ErrorAction SilentlyContinue
if ($null -eq $Collector -or $Collector.Status -ne 'Running') {
    Write-Warning 'Windows Event Collector (Wecsvc) is not running. Existing events can still be reported, but new forwarding may be affected.'
}

Write-Host "Reading $LogName on MGMT01 from $StartTime to $EndTime ..." -ForegroundColor Cyan

# ================================================
# SECTION 4 - READ FORWARDED EVENTS
# ================================================
$RawEvents = @()
try {
    $RawEvents = @(
        Get-WinEvent -FilterHashtable @{
            LogName   = $LogName
            StartTime = $StartTime
            EndTime   = $EndTime
        } -MaxEvents $MaxEvents -ErrorAction Stop
    )
}
catch {
    if ($_.FullyQualifiedErrorId -like '*NoMatchingEventsFound*') {
        Write-Warning 'No forwarded events were found in the chosen time window.'
    }
    else {
        throw "Could not read $LogName. $($_.Exception.Message)"
    }
}

if ($RawEvents.Count -ge $MaxEvents) {
    Write-Warning "Reached MaxEvents=$MaxEvents. This report may omit older events within the requested window. Increase -MaxEvents or shorten -Hours."
}

# ================================================
# SECTION 5 - CLASSIFY AND EXTRACT EVENTS
# ================================================
$Records = New-Object 'System.Collections.Generic.List[object]'

foreach ($Event in $RawEvents) {
    $Details = Get-ForwardedEventDetails -Event $Event
    $EventId = [int]$Event.Id
    $Level = [int]$Event.Level
    $Provider = [string]$Event.ProviderName

    $IsSecurity = ($Details.SourceLog -eq 'Security' -or
        $Provider -eq 'Microsoft-Windows-Security-Auditing')

    if ($IsSecurity -and $SecurityEventNames.ContainsKey($EventId)) {
        $Category = 'Identity/Security'
        $EventName = $SecurityEventNames[$EventId]
    }
    elseif (($Details.SourceLog -eq 'System' -or $Details.SourceLog -eq 'Application') -and
            ($Level -eq 1 -or $Level -eq 2)) {
        $Category = 'Infrastructure'
        $EventName = if ($Level -eq 1) { 'Critical infrastructure event' } else { 'Infrastructure error' }
    }
    else {
        continue
    }

    $Message = ''
    try {
        $Message = [string]$Event.Message
    }
    catch {
        $Message = 'Event message could not be formatted on this collector.'
    }
    $Message = [regex]::Replace($Message, '\s+', ' ').Trim()

    $SourceComputer = [string]$Event.MachineName
    if ([string]::IsNullOrWhiteSpace($SourceComputer)) { $SourceComputer = 'Unknown' }

    $Records.Add([PSCustomObject]@{
        TimeCreated   = $Event.TimeCreated
        SourceComputer = $SourceComputer
        SourceLog     = $Details.SourceLog
        Category      = $Category
        EventID       = $EventId
        EventName     = $EventName
        Level         = [string]$Event.LevelDisplayName
        TargetAccount = $Details.TargetAccount
        Actor         = $Details.Actor
        ClientIP      = $Details.ClientIP
        Provider      = $Provider
        RecordId      = $Event.RecordId
        Message       = $Message
    })
}

Write-Host "Read $($RawEvents.Count) forwarded event(s); selected $($Records.Count) relevant event(s)." -ForegroundColor Cyan

# ================================================
# SECTION 6 - SUMMARY AND CSV EXPORTS
# ================================================
$IdentityCount = @($Records | Where-Object { $_.Category -eq 'Identity/Security' }).Count
$InfrastructureCount = @($Records | Where-Object { $_.Category -eq 'Infrastructure' }).Count
$EventCount = $Records.Count

$Summary = @(
    [PSCustomObject]@{Category='Identity/Security'; Count=$IdentityCount}
    [PSCustomObject]@{Category='Infrastructure';  Count=$InfrastructureCount}
    [PSCustomObject]@{Category='Total relevant'; Count=$EventCount}
)

$null = New-Item -Path $OutputFolder -ItemType Directory -Force -ErrorAction Stop

if ($EventCount -gt 0) {
    $Records | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8
}
else {
    '"TimeCreated","SourceComputer","SourceLog","Category","EventID","EventName","Level","TargetAccount","Actor","ClientIP","Provider","RecordId","Message"' |
        Set-Content -LiteralPath $CsvPath -Encoding UTF8
}

$Summary | Export-Csv -LiteralPath $SummaryPath -NoTypeInformation -Encoding UTF8

Write-Host "`nEVENT SUMMARY" -ForegroundColor Cyan
$Summary | Format-Table -AutoSize
if ($EventCount -gt 0) {
    Write-Host 'Event IDs:' -ForegroundColor Cyan
    $Records | Group-Object EventID,EventName | Sort-Object Count -Descending |
        Select-Object Name,Count | Format-Table -AutoSize
}

# ================================================
# SECTION 7 - HTML REPORT
# ================================================
$Html = New-Object 'System.Collections.Generic.List[string]'
$Html.Add('<!DOCTYPE html>')
$Html.Add('<html lang="en"><head><meta charset="utf-8">')
$Html.Add('<title>Baron Lab - Centralised Event Report</title>')
$Html.Add('<style>body{font:14px Segoe UI,Arial,sans-serif;margin:32px;color:#20242b;background:#f7f9fc}h1{font-size:25px}h2{margin-top:32px}table{width:100%;border-collapse:collapse;background:white}th,td{border-bottom:1px solid #dfe4ed;padding:9px;text-align:left;vertical-align:top;overflow-wrap:anywhere}th{background:#eaf0f8}tr:nth-child(even){background:#f7fafd}.note{color:#505b6b}.summary{max-width:560px}code{background:#eee;padding:2px 4px}</style>')
$Html.Add('</head><body>')
$Html.Add('<h1>Centralised Event Report</h1>')
$Html.Add("<p class='note'>Collector: MGMT01 | Window: $(ConvertTo-SafeHtml $StartTime) to $(ConvertTo-SafeHtml $EndTime) | Read $($RawEvents.Count) forwarded events (limit: $MaxEvents)</p>")
if ($RawEvents.Count -ge $MaxEvents) {
    $Html.Add('<p><strong>Warning:</strong> Maximum event count was reached, so older events may be missing.</p>')
}
$Html.Add('<h2>Summary</h2><table class="summary"><tr><th>Category</th><th>Count</th></tr>')
foreach ($Item in $Summary) {
    $Html.Add("<tr><td>$(ConvertTo-SafeHtml $Item.Category)</td><td>$($Item.Count)</td></tr>")
}
$Html.Add('</table>')
$Html.Add("<h2>Recent matching events</h2><p class='note'>Showing up to $HtmlLimit most recent matching events. The CSV includes all selected events.</p>")
$Html.Add('<table><tr><th>Time</th><th>Computer</th><th>Source log</th><th>Event ID</th><th>Event</th><th>Target</th><th>Message excerpt</th></tr>')

if ($EventCount -eq 0) {
    $Html.Add('<tr><td colspan="7">No matching events in the selected period.</td></tr>')
}
else {
    foreach ($Row in @($Records | Sort-Object TimeCreated -Descending | Select-Object -First $HtmlLimit)) {
        $Excerpt = [string]$Row.Message
        if ($Excerpt.Length -gt 300) { $Excerpt = $Excerpt.Substring(0,300) + ' ...' }
        $Cells = @(
            $Row.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
            $Row.SourceComputer
            $Row.SourceLog
            [string]$Row.EventID
            $Row.EventName
            $Row.TargetAccount
            $Excerpt
        )
        $CellHtml = ($Cells | ForEach-Object { '<td>' + (ConvertTo-SafeHtml $_) + '</td>' }) -join ''
        $Html.Add("<tr>$CellHtml</tr>")
    }
}
$Html.Add('</table>')
$Html.Add('<p class="note">Read-only report. Events may contain personal or security-sensitive information. Absence of events is not proof of absence of activity.</p>')
$Html.Add('</body></html>')
$Html | Set-Content -LiteralPath $HtmlPath -Encoding UTF8

# ================================================
# SECTION 8 - VERIFY FILES AND DISPLAY PATHS
# ================================================
foreach ($FilePath in @($CsvPath,$SummaryPath,$HtmlPath)) {
    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        throw "The expected report file was not created: $FilePath"
    }
    if ((Get-Item -LiteralPath $FilePath).Length -eq 0) {
        throw "A report file is empty: $FilePath"
    }
}

Write-Host "Event CSV:   $CsvPath" -ForegroundColor Green
Write-Host "Summary CSV: $SummaryPath" -ForegroundColor Green
Write-Host "HTML report: $HtmlPath" -ForegroundColor Green
