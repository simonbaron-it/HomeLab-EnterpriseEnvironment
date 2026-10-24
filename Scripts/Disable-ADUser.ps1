#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [ValidateLength(3, 120)]
    [string]$Reason,

    [ValidateSet('DC01', 'DC02')]
    [string]$DomainController = 'DC01',

    [switch]$ClearContactAttributes
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --------------------------- SECTION 1: LAB SETTINGS ------------------------
$DomainName = 'baron.example.com'
$DisabledOU = 'OU=Disabled Users,OU=Baron Users,DC=baron,DC=example,DC=com'
$AllowedSourceOUs = @(
    'OU=Finance Staff,OU=Baron Users,DC=baron,DC=example,DC=com',
    'OU=HR Staff,OU=Baron Users,DC=baron,DC=example,DC=com',
    'OU=IT Staff,OU=Baron Users,DC=baron,DC=example,DC=com',
    'OU=Sales Staff,OU=Baron Users,DC=baron,DC=example,DC=com'
)
$ProtectedGroups = @(
    'IT_Admins', 'Domain Admins', 'Enterprise Admins', 'Schema Admins',
    'Administrators', 'Account Operators', 'Server Operators',
    'Backup Operators', 'Print Operators', 'Group Policy Creator Owners',
    'DnsAdmins'
)
$LogFolder = 'C:\LabAutomation\Logs\Offboarding'
$SnapshotFolder = Join-Path $LogFolder 'Snapshots'

# These variables record progress and support accurate failure reporting.
$User = $null
$DirectGroups = @()
$RemovedGroups = New-Object 'System.Collections.Generic.List[string]'
$SnapshotPath = ''
$Status = 'FAILED'
$Stage = 'Preflight'
$ErrorDetail = ''
$ChangesMade = $false
$ShouldWriteAudit = (-not $WhatIfPreference)
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

try {
    # ------------------------ SECTION 2: SAFE PREFLIGHT --------------------
    Import-Module ActiveDirectory -ErrorAction Stop

    $Domain = Get-ADDomain -Server $DomainController -ErrorAction Stop
    if ($Domain.DNSRoot -ne $DomainName) {
        throw "Wrong domain. Expected $DomainName but got $($Domain.DNSRoot)."
    }
    $null = Get-ADOrganizationalUnit -Identity $DisabledOU -Server $DomainController -ErrorAction Stop

    $User = Get-ADUser -Identity $Identity -Server $DomainController -Properties `
        Enabled, MemberOf, adminCount, Description, Department, Title, Manager, `
        telephoneNumber, mobile, ipPhone, mail -ErrorAction Stop

    $Guid = $User.ObjectGUID
    $Sam = $User.SamAccountName
    $OriginalDN = $User.DistinguishedName
    $OriginalDirectDNs = @($User.MemberOf | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    Write-Host "Found account: $Sam" -ForegroundColor Cyan
    Write-Host "Current OU/DN: $OriginalDN"
    Write-Host "Enabled: $($User.Enabled)"

    # Disallow built-in and protected/privileged users.
    if ($Sam -in @('Administrator', 'krbtgt') -or $User.SID.Value -match '-(500|502)$') {
        throw 'Built-in administrative/service accounts cannot be offboarded with this script.'
    }
    if ($User.adminCount -eq 1) {
        throw 'adminCount=1; this may be a protected/previously privileged account. Manual review required.'
    }

    # Already completed means no additional modifications are needed.
    if ($OriginalDN.EndsWith(",$DisabledOU", [StringComparison]::OrdinalIgnoreCase)) {
        if (-not $User.Enabled -and $OriginalDirectDNs.Count -eq 0) {
            $Status = 'SKIPPED'
            Write-Host 'Already disabled, in the Disabled Users OU and with no direct groups.' -ForegroundColor Yellow
            return
        }
        throw 'Account already in Disabled Users but its state needs manual review.'
    }

    $InApprovedOU = $false
    foreach ($SourceOU in $AllowedSourceOUs) {
        if ($OriginalDN.EndsWith(",$SourceOU", [StringComparison]::OrdinalIgnoreCase)) {
            $InApprovedOU = $true
            break
        }
    }
    if (-not $InApprovedOU) {
        throw 'User is not in an approved standard-employee OU. Administrator and other OUs are excluded.'
    }

    $AuthorizationGroups = @(Get-ADAccountAuthorizationGroup -Identity $User `
        -Server $DomainController -ErrorAction Stop)
    $MatchedPrivileged = @($AuthorizationGroups | Where-Object {
        $_.Name -in $ProtectedGroups -or $_.SamAccountName -in $ProtectedGroups
    })
    if ($MatchedPrivileged.Count -gt 0) {
        $GroupNames = ($MatchedPrivileged | ForEach-Object { $_.Name }) -join ', '
        throw "Privileged group membership detected ($GroupNames). Manual offboarding required."
    }

    foreach ($GroupDN in $OriginalDirectDNs) {
        $DirectGroups += Get-ADGroup -Identity $GroupDN -Server $DomainController -ErrorAction Stop
    }
    $GroupNames = @($DirectGroups | ForEach-Object { $_.Name })
    Write-Host "Direct groups to remove: $($GroupNames -join ', ')"
    if ($ClearContactAttributes) {
        Write-Host 'Optional clearing requested: manager, telephoneNumber, mobile, ipPhone'
    }

    # ------------------------- SECTION 3: APPROVAL ------------------------
    $Action = 'Disable account; remove direct groups; update description; move to Disabled Users'
    if ($ClearContactAttributes) { $Action += '; clear contact attributes' }
    if (-not $PSCmdlet.ShouldProcess($Sam, $Action)) {
        $Status = if ($WhatIfPreference) { 'PREVIEW' } else { 'SKIPPED' }
        Write-Host "[$Status] No AD changes made for $Sam." -ForegroundColor Yellow
        return
    }

    # -------------------------- SECTION 4: SNAPSHOT -----------------------
    $Stage = 'Saving pre-change snapshot'
    $null = New-Item -Path $SnapshotFolder -ItemType Directory -Force -ErrorAction Stop
    $SnapshotPath = Join-Path $SnapshotFolder "$Sam-$Timestamp.json"
    $Snapshot = [PSCustomObject]@{
        Time                 = Get-Date
        Operator             = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        DomainController     = $DomainController
        Reason               = $Reason
        SamAccountName       = $Sam
        ObjectGUID           = [string]$Guid
        OriginalDN           = $OriginalDN
        OriginallyEnabled    = [bool]$User.Enabled
        DirectGroupDNs       = @($OriginalDirectDNs)
        Description          = $User.Description
        Manager              = $User.Manager
        Department           = $User.Department
        Title                = $User.Title
        TelephoneNumber      = $User.telephoneNumber
        Mobile               = $User.mobile
        IpPhone              = $User.ipPhone
        Mail                 = $User.mail
    }
    $Snapshot | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $SnapshotPath -Encoding UTF8 -ErrorAction Stop
    Write-Host "Snapshot saved: $SnapshotPath" -ForegroundColor DarkCyan

    # ----------------------- SECTION 5: AD CHANGES ------------------------
    $Stage = 'Disabling account'
    Disable-ADAccount -Identity $Guid -Server $DomainController -Confirm:$false -ErrorAction Stop
    $ChangesMade = $true
    Write-Host "Disabled $Sam" -ForegroundColor Green

    $Stage = 'Removing direct group memberships'
    foreach ($Group in $DirectGroups) {
        Remove-ADGroupMember -Identity $Group.DistinguishedName -Members $User `
            -Server $DomainController -Confirm:$false -ErrorAction Stop
        $RemovedGroups.Add($Group.Name)
        Write-Host "Removed from $($Group.Name)"
    }

    if ($ClearContactAttributes) {
        $Stage = 'Clearing optional contact fields'
        Set-ADUser -Identity $Guid -Server $DomainController `
            -Clear @('manager', 'telephoneNumber', 'mobile', 'ipPhone') `
            -Confirm:$false -ErrorAction Stop
        Write-Host 'Cleared optional contact fields.'
    }

    $Stage = 'Writing offboarding description'
    $Description = "Offboarded $(Get-Date -Format 'yyyy-MM-dd') - $Reason"
    Set-ADUser -Identity $Guid -Server $DomainController `
        -Description $Description -Confirm:$false -ErrorAction Stop

    $Stage = 'Moving account'
    Move-ADObject -Identity $Guid -TargetPath $DisabledOU -Server $DomainController `
        -Confirm:$false -ErrorAction Stop
    Write-Host "Moved account to Disabled Users" -ForegroundColor Green

    # ------------------------- SECTION 6: VERIFY --------------------------
    $Stage = 'Verifying changes'
    $Updated = Get-ADUser -Identity $Guid -Server $DomainController `
        -Properties Enabled, MemberOf, Description -ErrorAction Stop
    $Remaining = @($Updated.MemberOf | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($Updated.Enabled) { throw 'Verification failed: account is still enabled.' }
    if (-not $Updated.DistinguishedName.EndsWith(",$DisabledOU", [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Verification failed: account is not in the Disabled Users OU.'
    }
    if ($Remaining.Count -gt 0) { throw 'Verification failed: direct group memberships remain.' }

    $Status = 'COMPLETED'
    Write-Host "[COMPLETED] $Sam disabled, groups removed, and OU verified." -ForegroundColor Green
}
catch {
    $ErrorDetail = "Stage '$Stage': $($_.Exception.Message)"
    $Status = if ($ChangesMade) { 'PARTIAL' } else { 'FAILED' }
    Write-Warning "[$Status] $ErrorDetail"

    if ($ChangesMade -and $User) {
        try {
            Disable-ADAccount -Identity $User.ObjectGUID -Server $DomainController `
                -Confirm:$false -ErrorAction Stop
        }
        catch {
            $ErrorDetail += " | SAFETY WARNING: Couldn't reconfirm account disabled: $($_.Exception.Message)"
            Write-Warning 'Account state could not be confirmed as disabled. Investigate immediately.'
        }
    }
}
finally {
    if ($ShouldWriteAudit) {
        try {
            $null = New-Item -Path $LogFolder -ItemType Directory -Force -ErrorAction Stop
            $LogPath = Join-Path $LogFolder "Offboarding-$Identity-$Timestamp.csv"
            [PSCustomObject]@{
                Time             = Get-Date
                Operator         = [Security.Principal.WindowsIdentity]::GetCurrent().Name
                Identity         = $Identity
                DomainController = $DomainController
                Reason           = $Reason
                Status           = $Status
                Stage            = $Stage
                OriginalDN       = if ($User) { $User.DistinguishedName } else { '' }
                RemovedGroups    = ($RemovedGroups -join '; ')
                SnapshotPath     = $SnapshotPath
                ErrorDetail      = $ErrorDetail
            } | Export-Csv -LiteralPath $LogPath -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
            Write-Host "Audit log: $LogPath" -ForegroundColor DarkCyan
        }
        catch {
            Write-Warning "Audit log write failed: $($_.Exception.Message)"
        }
    }
}

if ($Status -eq 'FAILED' -or $Status -eq 'PARTIAL') {
    throw "Offboarding $Status for '$Identity'. $ErrorDetail"
}
