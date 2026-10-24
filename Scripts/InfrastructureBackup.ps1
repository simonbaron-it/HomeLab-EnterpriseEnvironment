#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [ValidateRange(0,100)]
    [int]$MinFreeGB = 2
)

$ErrorActionPreference = 'Stop'

$BackupRoot = 'B:\InfrastructureBackups'
$DomainName = 'baron.example.com'
$DomainController = 'DC01'
$DhcpServer = 'DC01'
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$RunPath = Join-Path $BackupRoot $Timestamp

# A List is convenient for collecting each step's result.
$StepResults = New-Object 'System.Collections.Generic.List[object]'

function Add-StepResult {
    param(
        [string]$Step,
        [ValidateSet('PASS','FAIL')]
        [string]$Status,
        [string]$Detail
    )
    $StepResults.Add([PSCustomObject]@{
        Time   = (Get-Date).ToString('o')
        Step   = $Step
        Status = $Status
        Detail = $Detail
    })
    Write-Host "[$Status] $Step - $Detail"
}

function Assert-ExportFile {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Export missing: $Path"
    }
    if ((Get-Item -LiteralPath $Path).Length -le 0) {
        throw "Export is empty: $Path"
    }
}

# ------------------- PREFLIGHT: READ-ONLY -------------------
if ($env:COMPUTERNAME -ine 'DC01') {
    throw 'Run this script locally on DC01. B: is the DC01 backup volume.'
}
if (-not (Test-Path -LiteralPath 'B:\' -PathType Container)) {
    throw 'Backup volume B: is unavailable.'
}

$Volume = Get-Volume -DriveLetter B -ErrorAction Stop
$FreeGB = [math]::Round($Volume.SizeRemaining / 1GB, 2)
if ($FreeGB -lt $MinFreeGB) {
    throw "Only $FreeGB GB free on B:; at least $MinFreeGB GB required."
}

foreach ($Module in @('ActiveDirectory','GroupPolicy','DhcpServer','DnsServer')) {
    Import-Module -Name $Module -ErrorAction Stop
}

$ADDomain = Get-ADDomain -Server $DomainController -ErrorAction Stop
if ($ADDomain.DNSRoot -ine $DomainName) {
    throw "Wrong domain: expected $DomainName but found $($ADDomain.DNSRoot)."
}

$ExpectedGPOs = @(
    Get-GPO -All -Domain $DomainName -Server $DomainController -ErrorAction Stop
).Count
if ($ExpectedGPOs -lt 1) {
    throw 'No GPOs found; refusing to label an empty GPO backup successful.'
}

# Ensure DHCP can be queried before creating any files.
$null = @(Get-DhcpServerv4Scope -ComputerName $DhcpServer -ErrorAction Stop)

Write-Host "Target server: $env:COMPUTERNAME"
Write-Host "Domain: $DomainName | GPO count: $ExpectedGPOs | Free B: space: $FreeGB GB"
Write-Host "Planned output: $RunPath"

# The single top-level approval protects ALL filesystem writes.
if (-not $PSCmdlet.ShouldProcess($RunPath, 'Create GPO/DHCP/configuration exports and manifest')) {
    Write-Host '[PREVIEW] No folders or files created.'
    return
}

# ------------------- CREATE THE OUTPUT FOLDERS -------------------
if (Test-Path -LiteralPath $RunPath) {
    throw "Run directory already exists: $RunPath (wait one second and retry)."
}
$GpoPath = Join-Path $RunPath 'GPO'
$DhcpPath = Join-Path $RunPath 'DHCP'
$ConfigPath = Join-Path $RunPath 'Config'
foreach ($Folder in @($GpoPath,$DhcpPath,$ConfigPath)) {
    $null = New-Item -Path $Folder -ItemType Directory -ErrorAction Stop
}

# ------------------- 1. GPO BACKUP -------------------
$ActualGPOs = 0
try {
    $Backups = @(
        Backup-GPO -All -Path $GpoPath -Domain $DomainName `
            -Server $DomainController -Comment "Baron lab $Timestamp" -ErrorAction Stop
    )
    $ActualGPOs = $Backups.Count
    $GpoFiles = @(Get-ChildItem -LiteralPath $GpoPath -File -Recurse -ErrorAction Stop)
    if ($ActualGPOs -ne $ExpectedGPOs -or $GpoFiles.Count -eq 0) {
        throw "Expected $ExpectedGPOs backups, returned $ActualGPOs; files found: $($GpoFiles.Count)."
    }
    Add-StepResult -Step 'GPO backup' -Status PASS -Detail "$ActualGPOs of $ExpectedGPOs GPOs exported."
}
catch {
    Add-StepResult -Step 'GPO backup' -Status FAIL -Detail $_.Exception.Message
}

# ------------------- 2. DHCP EXPORT -------------------
$DhcpFile = Join-Path $DhcpPath 'DHCP-Config-and-Leases.xml'
try {
    Export-DhcpServer -ComputerName $DhcpServer -File $DhcpFile `
        -Leases -Force -ErrorAction Stop
    Assert-ExportFile -Path $DhcpFile
    # Parse the file to ensure that it is at least well-formed XML.
    $null = [xml](Get-Content -LiteralPath $DhcpFile -Raw -ErrorAction Stop)
    Add-StepResult -Step 'DHCP export' -Status PASS -Detail 'DHCP configuration and leases exported; XML parsed.'
}
catch {
    Add-StepResult -Step 'DHCP export' -Status FAIL -Detail $_.Exception.Message
}

# ------------------- 3. INVENTORY EXPORTS -------------------
$Inventories = @(
    @{ Name='AD domain';       File='AD-Domain.xml';       Read={ Get-ADDomain -Server 'DC01' } },
    @{ Name='AD forest';       File='AD-Forest.xml';       Read={ Get-ADForest -Server 'DC01' } },
    @{ Name='Domain controllers';File='DomainControllers.xml';Read={ Get-ADDomainController -Filter * -Server 'DC01' } },
    @{ Name='Organisational units';File='OrganisationalUnits.xml';Read={ Get-ADOrganizationalUnit -Filter * -Server 'DC01' | Select-Object Name,DistinguishedName } },
    @{ Name='Security groups'; File='Groups.xml';         Read={ Get-ADGroup -Filter * -Server 'DC01' | Select-Object Name,GroupScope,GroupCategory,DistinguishedName } },
    @{ Name='DNS zones';       File='DNS-Zones.xml';       Read={ Get-DnsServerZone -ComputerName 'DC01' } },
    @{ Name='DHCP scopes';     File='DHCP-Scopes.xml';     Read={ Get-DhcpServerv4Scope -ComputerName 'DC01' } },
    @{ Name='DHCP failover';   File='DHCP-Failover.xml';   Read={ Get-DhcpServerv4Failover -ComputerName 'DC01' } }
)

foreach ($Inventory in $Inventories) {
    $FilePath = Join-Path $ConfigPath $Inventory.File
    try {
        $Items = @(& ($Inventory.Read))
        if ($Items.Count -eq 0) {
            throw 'Query returned no records.'
        }
        $Items | Export-Clixml -LiteralPath $FilePath -ErrorAction Stop
        Assert-ExportFile -Path $FilePath
        Add-StepResult -Step $Inventory.Name -Status PASS -Detail "$($Items.Count) record(s) exported."
    }
    catch {
        Add-StepResult -Step $Inventory.Name -Status FAIL -Detail $_.Exception.Message
    }
}

# ------------------- 4. FILE INVENTORY AND HASHES -------------------
$Hashes = @()
try {
    $ExportFiles = @(Get-ChildItem -LiteralPath $RunPath -Recurse -File -ErrorAction Stop)
    if ($ExportFiles.Count -eq 0) {
        throw 'No export files were created.'
    }
    $Hashes = @(
        foreach ($File in $ExportFiles) {
            $Sha = Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256 -ErrorAction Stop
            [PSCustomObject]@{
                RelativePath = $File.FullName.Substring($RunPath.Length).TrimStart('\')
                Bytes        = $File.Length
                SHA256       = $Sha.Hash
            }
        }
    )
    Add-StepResult -Step 'SHA256 manifest' -Status PASS -Detail "$($Hashes.Count) file(s) hashed."
}
catch {
    Add-StepResult -Step 'SHA256 manifest' -Status FAIL -Detail $_.Exception.Message
}

# ------------------- 5. WRITE MANIFEST LAST -------------------
$Failures = @($StepResults | Where-Object { $_.Status -eq 'FAIL' }).Count
$RunStatus = if ($Failures -eq 0) { 'PASS' } else { 'PARTIAL' }
$Manifest = [PSCustomObject]@{
    StartTimestamp  = $Timestamp
    CompletedAt     = (Get-Date).ToString('o')
    SourceServer    = $env:COMPUTERNAME
    Operator        = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    Domain          = $DomainName
    OutputPath      = $RunPath
    FreeGBAtStart   = $FreeGB
    ExpectedGPOs    = $ExpectedGPOs
    BackedUpGPOs    = $ActualGPOs
    OverallStatus   = $RunStatus
    Results         = @($StepResults.ToArray())
    Files           = @($Hashes)
}
$ManifestPath = Join-Path $RunPath 'BackupManifest.json'
$Manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $ManifestPath -Encoding UTF8 -ErrorAction Stop
Assert-ExportFile -Path $ManifestPath
$null = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json

Write-Host ''
Write-Host "Configuration export run: $RunStatus"
$StepResults | Format-Table Step,Status,Detail -AutoSize
Write-Host "Manifest: $ManifestPath"
if ($Failures -gt 0) {
    Write-Warning "$Failures step(s) failed. Review BackupManifest.json before treating this run as complete."
}
