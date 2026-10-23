#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,

    [ValidateSet('DC01', 'DC02')]
    [string]$DomainController = 'DC01',

    [string]$LogFolder = 'C:\LabAutomation\Logs'
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory -ErrorAction Stop

# ==========================================
# SECTION 1 - APPROVED LAB CONFIGURATION
# ==========================================
$DomainName = 'baron.example.com'
$DepartmentMap = @{
    Finance = @{
        OU = 'OU=Finance Staff,OU=Baron Users,DC=baron,DC=example,DC=com'
        UserGroup = 'Finance_Users'
        ManagerGroup = 'Finance_Managers'
    }
    HR = @{
        OU = 'OU=HR Staff,OU=Baron Users,DC=baron,DC=example,DC=com'
        UserGroup = 'HR_Users'
        ManagerGroup = 'HR_Managers'
    }
    IT = @{
        OU = 'OU=IT Staff,OU=Baron Users,DC=baron,DC=example,DC=com'
        UserGroup = 'IT_Users'
        ManagerGroup = $null
    }
    Sales = @{
        OU = 'OU=Sales Staff,OU=Baron Users,DC=baron,DC=example,DC=com'
        UserGroup = 'Sales_Users'
        ManagerGroup = $null
    }
}

# ==========================================
# SECTION 2 - REUSABLE FUNCTIONS
# ==========================================
function Get-LabUsername {

    param(
        [string]$FirstName,
        [string]$LastName
    )

    # Take the first letter of the first name.
    $FirstInitial = $FirstName.Trim().Substring(0,1)

    # Combine the initial and surname.
    $Username = "$FirstInitial$($LastName.Trim())".ToLower()

    # Ensure the username contains only letters.
    if ($Username -notmatch "^[a-z]+$") {
        throw "Username contains unsupported characters"
    }

    # Check the username length.
    if ($Username.Length -gt 20) {
        throw "Username is too long"
    }

    return $Username
}

$Results = New-Object 'System.Collections.Generic.List[object]'
function Add-OnboardingResult {
    param(
        [int]$RowNumber,
        [string]$Username,
        [string]$Department,
        [string]$Role,
        [string]$Groups,
        [string]$Status,
        [string]$Detail
    )
    $Results.Add([PSCustomObject]@{
        Time = Get-Date
        Operator = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        Row = $RowNumber
        Username = $Username
        Department = $Department
        Role = $Role
        Groups = $Groups
        Status = $Status
        Detail = $Detail
    })
    Write-Host ("[{0}] Row {1}: {2} - {3}" -f $Status, $RowNumber, $Username, $Detail)
}

# ==========================================
# SECTION 3 - READ INPUT AND CHECK AD
# ==========================================
if (-not (Test-Path -LiteralPath $CsvPath -PathType Leaf)) {
    throw "CSV file not found: $CsvPath"
}

$Rows = @(Import-Csv -LiteralPath $CsvPath -ErrorAction Stop)
if ($Rows.Count -eq 0) {
    throw 'CSV contains no data rows.'
}

$RequiredColumns = @('FirstName', 'LastName', 'Department', 'Role', 'JobTitle')
$ActualColumns = @($Rows[0].PSObject.Properties.Name)
foreach ($Column in $RequiredColumns) {
    if ($ActualColumns -notcontains $Column) {
        throw "Missing required CSV column: $Column"
    }
}

$Domain = Get-ADDomain -Server $DomainController -ErrorAction Stop
if ($Domain.DNSRoot -ne $DomainName) {
    throw "Connected to unexpected domain '$($Domain.DNSRoot)'. Expected '$DomainName'."
}

Write-Host "Loaded $($Rows.Count) CSV record(s). Target DC: $DomainController" -ForegroundColor Cyan
if ($WhatIfPreference) {
    Write-Host 'PREVIEW MODE: No users will be created, changed or enabled.' -ForegroundColor Yellow
}

$SeenUsernames = @{}
$RowNumber = 1   # CSV header occupies row 1.

# ==========================================
# SECTION 4 - VALIDATE AND PROCESS EACH ROW
# ==========================================
foreach ($Row in $Rows) {
    $RowNumber++
    $Username = '(not generated)'
    $Department = [string]$Row.Department
    $Role = [string]$Row.Role
    $GroupText = ''
    $CreatedUser = $null
    $TempPassword = $null

    try {
        foreach ($Column in $RequiredColumns) {
            if ([string]::IsNullOrWhiteSpace([string]$Row.$Column)) {
                throw "Column '$Column' is empty."
            }
        }

        $FirstName = $Row.FirstName.Trim()
        $LastName = $Row.LastName.Trim()
        $Department = $Row.Department.Trim()
        $Role = $Row.Role.Trim()
        $JobTitle = $Row.JobTitle.Trim()

        if (-not $DepartmentMap.ContainsKey($Department)) {
            throw "Unknown department '$Department'. Allowed: Finance, HR, IT, Sales."
        }
        if ($Role -notin @('User', 'Manager')) {
            throw "Unknown role '$Role'. Allowed: User or Manager."
        }

        $Config = $DepartmentMap[$Department]
        if ($Role -eq 'Manager' -and [string]::IsNullOrWhiteSpace($Config.ManagerGroup)) {
            throw "The '$Department' department has no approved Manager group in this lab."
        }

        $Username = Get-LabUsername -FirstName $FirstName -LastName $LastName
        if ($SeenUsernames.ContainsKey($Username)) {
            throw "Duplicate username '$Username' in this CSV. Review the rows manually."
        }
        $SeenUsernames[$Username] = $true

        $Groups = @($Config.UserGroup)
        if ($Role -eq 'Manager') {
            $Groups += $Config.ManagerGroup
        }
        $GroupText = $Groups -join '; '

        $null = Get-ADOrganizationalUnit -Identity $Config.OU -Server $DomainController -ErrorAction Stop
        foreach ($GroupName in $Groups) {
            $ADGroup = Get-ADGroup -Identity $GroupName -Server $DomainController -ErrorAction Stop
            if ($ADGroup.GroupCategory -ne 'Security' -or $ADGroup.GroupScope -ne 'Global') {
                throw "Group '$GroupName' must be a Global Security group."
            }
        }

        $ExistingUser = Get-ADUser -LDAPFilter "(sAMAccountName=$Username)" -Server $DomainController -ErrorAction Stop
        if ($null -ne $ExistingUser) {
            Add-OnboardingResult -RowNumber $RowNumber -Username $Username `
                -Department $Department -Role $Role -Groups $GroupText `
                -Status 'SKIPPED' -Detail 'Username already exists in AD; review manually.'
            continue
        }

        $TargetDescription = "$Username in $($Config.OU) with groups: $GroupText"
        if (-not $PSCmdlet.ShouldProcess($TargetDescription, 'Create user, set temporary password, add groups, enable')) {
            $PreviewStatus = if ($WhatIfPreference) { 'PREVIEW' } else { 'SKIPPED' }
            Add-OnboardingResult -RowNumber $RowNumber -Username $Username `
                -Department $Department -Role $Role -Groups $GroupText `
                -Status $PreviewStatus -Detail 'No AD changes made.'
            continue
        }

        $TempPassword = Read-Host "Temporary password for $Username" -AsSecureString
        if ($null -eq $TempPassword -or $TempPassword.Length -eq 0) {
            throw 'No temporary password supplied.'
        }

        $CreateArgs = @{
            Name = "$FirstName $LastName"
            GivenName = $FirstName
            Surname = $LastName
            DisplayName = "$FirstName $LastName"
            SamAccountName = $Username
            UserPrincipalName = "$Username@$DomainName"
            Department = $Department
            Title = $JobTitle
            Path = $Config.OU
            AccountPassword = $TempPassword
            ChangePasswordAtLogon = $true
            Enabled = $false
            Server = $DomainController
            PassThru = $true
            ErrorAction = 'Stop'
        }
        $CreatedUser = New-ADUser @CreateArgs

        foreach ($GroupName in $Groups) {
            Add-ADGroupMember -Identity $GroupName -Members $CreatedUser `
                -Server $DomainController -ErrorAction Stop
        }

        Enable-ADAccount -Identity $CreatedUser.ObjectGUID -Server $DomainController -ErrorAction Stop

        Set-ADUser `
    -Identity $CreatedUser.ObjectGUID `
    -Server $DomainController `
    -ChangePasswordAtLogon $true `
    -ErrorAction Stop

        $Verified = Get-ADUser -Identity $CreatedUser.ObjectGUID -Server $DomainController `
            -Properties Enabled, MemberOf, pwdLastSet -ErrorAction Stop
        if (-not $Verified.Enabled) {
            throw 'Account could not be verified as enabled.'
        }
        foreach ($GroupName in $Groups) {
            $ExpectedGroup = Get-ADGroup -Identity $GroupName -Server $DomainController -ErrorAction Stop
            if ($Verified.MemberOf -notcontains $ExpectedGroup.DistinguishedName) {
                throw "Missing expected membership: $GroupName"
            }
        }
        if ([int64]$Verified.pwdLastSet -ne 0) {
            throw 'Password-change-at-next-logon requirement was not verified.'
        }

        Add-OnboardingResult -RowNumber $RowNumber -Username $Username `
            -Department $Department -Role $Role -Groups $GroupText `
            -Status 'CREATED' -Detail 'Enabled, groups and password-change requirement verified.'
    }
    catch {
        $ErrorText = $_.Exception.Message -replace '\s+', ' '
        $Outcome = 'FAILED'
        if ($null -ne $CreatedUser) {
            $Outcome = 'PARTIAL'
            try {
                Disable-ADAccount -Identity $CreatedUser.ObjectGUID `
                    -Server $DomainController -ErrorAction Stop
                $ErrorText += ' Created account has been disabled for review.'
            }
            catch {
                $ErrorText += " WARNING: Could not confirm disabling the partial account: $($_.Exception.Message)"
            }
        }
        Add-OnboardingResult -RowNumber $RowNumber -Username $Username `
            -Department $Department -Role $Role -Groups $GroupText `
            -Status $Outcome -Detail $ErrorText
    }
    finally {
        $TempPassword = $null
    }
}

# ==========================================
# SECTION 5 - DISPLAY AND WRITE AUDIT LOG
# ==========================================
$Results | Format-Table Row, Username, Department, Role, Status, Detail -AutoSize
$Results | Group-Object Status | Select-Object Name, Count | Format-Table -AutoSize

if ($WhatIfPreference) {
    Write-Host 'Preview finished. No accounts or log files changed.' -ForegroundColor Yellow
}
else {
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    $Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $LogPath = Join-Path $LogFolder "Onboarding-$Stamp.csv"
    $Results | Export-Csv -LiteralPath $LogPath -NoTypeInformation -Encoding UTF8
    Write-Host "Audit log saved to: $LogPath" -ForegroundColor Cyan
}
