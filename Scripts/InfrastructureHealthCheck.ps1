#Requires -Version 5.1

# ===== SECTION 1: LAB CONFIGURATION =====
$Servers = @('DC01', 'DC02', 'FS01', 'MGMT01')
$DomainControllers = @('DC01', 'DC02')
$DnsServers = @('10.10.10.10', '10.10.10.11')
$DnsRecords = [ordered]@{
    'DC01.baron.example.com'   = '10.10.10.10'
    'DC02.baron.example.com'   = '10.10.10.11'
    'FS01.baron.example.com'   = '10.10.10.20'
    'MGMT01.baron.example.com' = '10.10.10.30'
}
$CriticalServices = [ordered]@{
    DC01   = @('NTDS', 'DNS', 'DHCPServer', 'Netlogon', 'KDC')
    DC02   = @('NTDS', 'DNS', 'DHCPServer', 'Netlogon', 'KDC')
    FS01   = @('LanmanServer')
    MGMT01 = @('WinRM', 'Wecsvc', 'WindowsAdminCenter')
}
# Static IPs let the quick connectivity check avoid DNS lookup delays.
$ServerIPs = [ordered]@{
    DC01 = '10.10.10.10'
    DC02 = '10.10.10.11'
    FS01 = '10.10.10.20'
    MGMT01 = '10.10.10.30'
}
$RemoteAvailable = @{}
$ReportFolder = 'C:\LabAutomation\Output'
$Results = @()

# ===== SECTION 2: REUSABLE REPORT-ROW FUNCTION =====
function New-CheckResult {
    param(
        [string]$Category,
        [string]$Target,
        [string]$Check,
        [ValidateSet('PASS', 'WARN', 'FAIL')]
        [string]$Status,
        [string]$Detail
    )
    [PSCustomObject]@{
        Time     = Get-Date
        Category = $Category
        Target   = $Target
        Check    = $Check
        Status   = $Status
        Detail   = $Detail
    }
}

function Add-CheckResult {
    param(
        [string]$Category,
        [string]$Target,
        [string]$Check,
        [ValidateSet('PASS', 'WARN', 'FAIL')][string]$Status,
        [string]$Detail
    )
    $Row = New-CheckResult -Category $Category -Target $Target -Check $Check -Status $Status -Detail $Detail
    $script:Results += $Row
    $Colour = switch ($Status) {
        'PASS' { 'Green' }
        'WARN' { 'Yellow' }
        default { 'Red' }
    }
    Write-Host ("[{0}] {1,-4} {2,-18} {3,-20} {4}" -f (Get-Date -Format 'HH:mm:ss'), $Status, $Target, $Check, $Detail) -ForegroundColor $Colour
}

# ===== SECTION 3: QUICK AVAILABILITY CHECK =====
function Test-TcpPortQuick {
    param(
        [Parameter(Mandatory)][string]$Address,
        [int]$Port = 5985,
        [int]$TimeoutMilliseconds = 2000
    )

    $Client = New-Object System.Net.Sockets.TcpClient
    $Async = $null
    try {
        $Async = $Client.BeginConnect($Address, $Port, $null, $null)
        if (-not $Async.AsyncWaitHandle.WaitOne($TimeoutMilliseconds)) {
            return $false
        }
        $Client.EndConnect($Async)
        return $true
    }
    catch {
        return $false
    }
    finally {
        if ($null -ne $Async) { $Async.AsyncWaitHandle.Close() }
        $Client.Close()
    }
}

Write-Host 'Checking host reachability (2-second WinRM precheck)...' -ForegroundColor Cyan
foreach ($Server in $Servers) {
    $Available = Test-TcpPortQuick -Address $ServerIPs[$Server]
    $RemoteAvailable[$Server] = $Available

    if ($Available) {
        Add-CheckResult -Category 'Connectivity' -Target $Server -Check 'WinRM TCP/5985' -Status 'PASS' -Detail 'Management port reachable'
    }
    else {
        Add-CheckResult -Category 'Connectivity' -Target $Server -Check 'WinRM TCP/5985' -Status 'FAIL' -Detail 'Management port unreachable within 2 seconds; further remote checks skipped'
    }
}

$SessionOptions = New-PSSessionOption -OpenTimeout 5000 -OperationTimeout 10000

# ===== SECTION 4: CRITICAL WINDOWS SERVICES =====
foreach ($Server in $CriticalServices.Keys) {
    foreach ($ServiceName in $CriticalServices[$Server]) {
        if ($Server -ne $env:COMPUTERNAME -and -not $RemoteAvailable[$Server]) {
            Add-CheckResult -Category 'Services' -Target $Server -Check $ServiceName -Status 'FAIL' -Detail 'Not checked: WinRM port unreachable (service state unknown)'
            continue
        }
        try {
            if ($Server -eq $env:COMPUTERNAME) {
                $ServiceState = (Get-Service -Name $ServiceName -ErrorAction Stop).Status.ToString()
            }
            else {
                $ServiceState = Invoke-Command -ComputerName $Server -ArgumentList $ServiceName -ErrorAction Stop -SessionOption $SessionOptions -ScriptBlock {
                    param($Name)
                    (Get-Service -Name $Name -ErrorAction Stop).Status.ToString()
                }
            }
            $Status = if ($ServiceState -eq 'Running') { 'PASS' } else { 'FAIL' }
            Add-CheckResult -Category 'Services' -Target $Server -Check $ServiceName -Status $Status -Detail "Service state: $ServiceState"
        }
        catch {
            Add-CheckResult -Category 'Services' -Target $Server -Check $ServiceName -Status 'FAIL' -Detail $_.Exception.Message
        }
    }
}

# ===== SECTION 5: DNS RECORDS VIA BOTH DOMAIN CONTROLLERS =====
foreach ($DnsServer in $DnsServers) {
    foreach ($HostName in $DnsRecords.Keys) {
        $ExpectedIP = $DnsRecords[$HostName]
        $DnsHost = if ($DnsServer -eq $ServerIPs['DC01']) { 'DC01' } else { 'DC02' }
        if (-not $RemoteAvailable[$DnsHost]) {
            Add-CheckResult -Category 'DNS' -Target $DnsServer -Check $HostName -Status 'WARN' -Detail 'Not queried: DNS host failed WinRM precheck (DNS status unknown)'
            continue
        }
        try {
            $Answers = @(Resolve-DnsName -Name $HostName -Server $DnsServer -Type A -DnsOnly -QuickTimeout -ErrorAction Stop)
            $MatchingAnswer = @($Answers | Where-Object { $_.IPAddress -eq $ExpectedIP })
            if ($MatchingAnswer.Count -gt 0) {
                $Status = 'PASS'
                $Detail = "Expected address $ExpectedIP returned"
            }
            else {
                $Status = 'FAIL'
                $Detail = "DNS answered, but not with the expected address $ExpectedIP"
            }
        }
        catch {
            $Status = 'FAIL'
            $Detail = $_.Exception.Message
        }
        Add-CheckResult -Category 'DNS' -Target $DnsServer -Check $HostName -Status $Status -Detail $Detail
    }
}

# ===== SECTION 6: AD REPLICATION =====
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    foreach ($DC in $DomainControllers) {
        if (-not $RemoteAvailable[$DC]) {
            Add-CheckResult -Category 'Active Directory' -Target $DC -Check 'Replication' -Status 'FAIL' -Detail 'Not checked: domain controller management port unavailable'
            continue
        }
        try {
            $Partners = @(Get-ADReplicationPartnerMetadata -Target $DC -Scope Server -PartnerType Inbound -EnumerationServer $DC -ErrorAction Stop)
            if ($Partners.Count -eq 0) {
                $Status = 'WARN'
                $Detail = 'No inbound replication partner data returned'
            }
            else {
                $FailedPartners = @($Partners | Where-Object { $_.LastReplicationResult -ne 0 -or -not $_.LastReplicationSuccess })
                if ($FailedPartners.Count -eq 0) {
                    $Status = 'PASS'
                    $Detail = "Last attempt successful for $($Partners.Count) inbound replication link(s)"
                }
                else {
                    $Status = 'FAIL'
                    $Detail = "$($FailedPartners.Count) of $($Partners.Count) inbound replication link(s) need investigation"
                }
            }
            Add-CheckResult -Category 'Active Directory' -Target $DC -Check 'Replication' -Status $Status -Detail $Detail
        }
        catch {
            Add-CheckResult -Category 'Active Directory' -Target $DC -Check 'Replication' -Status 'FAIL' -Detail $_.Exception.Message
        }
    }
}
catch {
    Add-CheckResult -Category 'Active Directory' -Target 'MGMT01' -Check 'RSAT module' -Status 'FAIL' -Detail $_.Exception.Message
}

# ===== SECTION 7: SYSVOL AND NETLOGON SHARES =====
foreach ($DC in $DomainControllers) {
    foreach ($Share in @('SYSVOL', 'NETLOGON')) {
        if (-not $RemoteAvailable[$DC]) {
            Add-CheckResult -Category 'Active Directory' -Target $DC -Check $Share -Status 'FAIL' -Detail 'Not checked: domain controller management port unavailable'
            continue
        }
        $Path = "\\$DC\$Share"
        try {
            $Accessible = Test-Path -LiteralPath $Path -ErrorAction Stop
            $Status = if ($Accessible) { 'PASS' } else { 'FAIL' }
            $Detail = if ($Accessible) { 'Share accessible from MGMT01' } else { 'Share not accessible from MGMT01' }
            Add-CheckResult -Category 'Active Directory' -Target $DC -Check $Share -Status $Status -Detail $Detail
        }
        catch {
            Add-CheckResult -Category 'Active Directory' -Target $DC -Check $Share -Status 'FAIL' -Detail $_.Exception.Message
        }
    }
}

# ===== SECTION 8: FSMO ROLES =====
try {
    # Ask whichever domain controller is available, not always DC01.
    $DomainInfo = $null
    $ForestInfo = $null
    foreach ($DC in $DomainControllers) {
        if (-not $RemoteAvailable[$DC]) { continue }
        try {
            $DomainInfo = Get-ADDomain -Server $DC -ErrorAction Stop
            $ForestInfo = Get-ADForest -Server $DC -ErrorAction Stop
            break
        }
        catch { }
    }
    if (-not $DomainInfo -or -not $ForestInfo) {
        throw 'Neither DC returned domain and forest information'
    }
    $FsmoRoles = [ordered]@{
        PDCEmulator          = $DomainInfo.PDCEmulator
        RIDMaster            = $DomainInfo.RIDMaster
        InfrastructureMaster = $DomainInfo.InfrastructureMaster
        SchemaMaster         = $ForestInfo.SchemaMaster
        DomainNamingMaster   = $ForestInfo.DomainNamingMaster
    }
    foreach ($Role in $FsmoRoles.Keys) {
        $Owner = [string]$FsmoRoles[$Role]
        if ([string]::IsNullOrWhiteSpace($Owner)) {
            Add-CheckResult -Category 'Active Directory' -Target 'Domain' -Check $Role -Status 'FAIL' -Detail 'Role holder not reported'
            continue
        }
        $OwnerShortName = ($Owner -split '\.')[0].ToUpperInvariant()
        if ($RemoteAvailable.ContainsKey($OwnerShortName)) {
            $OwnerOnline = $RemoteAvailable[$OwnerShortName]
        }
        else {
            $OwnerOnline = Test-Connection -ComputerName $Owner -Count 1 -Quiet -ErrorAction SilentlyContinue
        }
        $Status = if ($OwnerOnline) { 'PASS' } else { 'WARN' }
        Add-CheckResult -Category 'Active Directory' -Target $Owner -Check $Role -Status $Status -Detail 'FSMO role owner identified; availability based on WinRM precheck for lab DCs'
    }
}
catch {
    Add-CheckResult -Category 'Active Directory' -Target 'Domain' -Check 'FSMO discovery' -Status 'FAIL' -Detail $_.Exception.Message
}

# ===== SECTION 9: DHCP FAILOVER =====
try {
    Import-Module DhcpServer -ErrorAction Stop
    foreach ($DC in $DomainControllers) {
        if (-not $RemoteAvailable[$DC]) {
            Add-CheckResult -Category 'DHCP' -Target $DC -Check 'Failover' -Status 'FAIL' -Detail 'Not queried: DHCP host management port unavailable'
            continue
        }
        try {
            $Failover = Get-DhcpServerv4Failover -ComputerName $DC -Name 'DC01-DC02-Failover' -ErrorAction Stop
            $State = [string]$Failover.State
            $Mode  = [string]$Failover.Mode
            $Status = if ($State -eq 'Normal' -and $Mode -eq 'LoadBalance') { 'PASS' } else { 'WARN' }
            Add-CheckResult -Category 'DHCP' -Target $DC -Check 'Failover' -Status $Status -Detail "State: $State; Mode: $Mode"
        }
        catch {
            Add-CheckResult -Category 'DHCP' -Target $DC -Check 'Failover' -Status 'FAIL' -Detail $_.Exception.Message
        }
    }
}
catch {
    Add-CheckResult -Category 'DHCP' -Target 'MGMT01' -Check 'RSAT module' -Status 'FAIL' -Detail $_.Exception.Message
}

# ===== SECTION 10: FILE SHARE =====
$SharePath = '\\FS01\CompanyData'
if (-not $RemoteAvailable['FS01']) {
    Add-CheckResult -Category 'File Services' -Target 'FS01' -Check 'CompanyData' -Status 'FAIL' -Detail 'Not checked: FS01 management port unavailable'
}
else {
try {
    $ShareAccessible = Test-Path -LiteralPath $SharePath -ErrorAction Stop
    $Status = if ($ShareAccessible) { 'PASS' } else { 'FAIL' }
    $Detail = if ($ShareAccessible) { 'Share accessible from MGMT01' } else { 'Share not accessible from MGMT01' }
    Add-CheckResult -Category 'File Services' -Target 'FS01' -Check 'CompanyData' -Status $Status -Detail $Detail
}
catch {
    Add-CheckResult -Category 'File Services' -Target 'FS01' -Check 'CompanyData' -Status 'FAIL' -Detail $_.Exception.Message
}

}

# ===== SECTION 11: FREE DISK SPACE =====
foreach ($Server in $Servers) {
    if ($Server -ne $env:COMPUTERNAME -and -not $RemoteAvailable[$Server]) {
        Add-CheckResult -Category 'Storage' -Target $Server -Check 'Disk query' -Status 'FAIL' -Detail 'Not checked: server management port unavailable'
        continue
    }
    try {
        if ($Server -eq $env:COMPUTERNAME) {
            $Disks = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop)
        }
        else {
            $Disks = @(Invoke-Command -ComputerName $Server -ErrorAction Stop -SessionOption $SessionOptions -ScriptBlock {
                Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop |
                    Select-Object DeviceID, Size, FreeSpace
            })
        }
        if ($Disks.Count -eq 0) { throw 'No fixed disks returned' }
        foreach ($Disk in $Disks) {
            if ($Disk.Size -le 0) { continue }
            $FreePercent = [math]::Round(100 * $Disk.FreeSpace / $Disk.Size, 1)
            if ($FreePercent -lt 10) { $Status = 'FAIL' }
            elseif ($FreePercent -lt 20) { $Status = 'WARN' }
            else { $Status = 'PASS' }
            Add-CheckResult -Category 'Storage' -Target $Server -Check "$($Disk.DeviceID) free space" -Status $Status -Detail "$FreePercent% free"
        }
    }
    catch {
        Add-CheckResult -Category 'Storage' -Target $Server -Check 'Disk query' -Status 'FAIL' -Detail $_.Exception.Message
    }
}

# ===== SECTION 12: REPORT AND EXPORT =====
New-Item -Path $ReportFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$ReportPath = Join-Path $ReportFolder "InfrastructureHealth-$Timestamp.csv"

$Results | Sort-Object Category, Target, Check | Format-Table Category, Target, Check, Status, Detail -AutoSize
$Results | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8

Write-Host "`nRESULT SUMMARY" -ForegroundColor Cyan
$Results | Group-Object Status | Sort-Object Name | Select-Object Name, Count | Format-Table -AutoSize
Write-Host "CSV report saved: $ReportPath" -ForegroundColor Cyan
