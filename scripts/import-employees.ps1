# ============================================================
# DATA LOADING
# ============================================================

$json = Get-Content "./data/employees.json" -Encoding UTF8
$data = $json | ConvertFrom-Json

$roles_json = Get-Content "./data/roles.json" -Encoding UTF8
$roles = $roles_json | ConvertFrom-Json

$references_json = Get-Content "./data/references.json" -Encoding UTF8
$references = $references_json | ConvertFrom-Json


# ============================================================
# USERNAME GENERATION
# ============================================================
<#
Add a base username to each employee.
Example :
id          : EMP0000
first_name  : Marine
last_name   : Furlan
[...]
username    : mfurlan
#>

$employees = foreach ($employee in $data.employees) {
    $firstletter = $employee.first_name.Substring(0,1)
    $username = ($firstletter+$employee.last_name).ToLower().Normalize("FormD") -replace "\p{M}"
    $employee | Add-Member -MemberType NoteProperty -Name "username" -Value $username
    $employee
}


# ============================================================
# COLLISION DETECTION
# ============================================================

$collisions = $employees | Group-Object -Property username | Where-Object Count -GT 1


# ============================================================
# COLLISION RESOLUTION
# ============================================================
<# Each employee having the same username will have a new one using number iterations
Example :
id          : EMP0000
first_name  : Marine
last_name   : Furlan
[...]
username    : mfurlan01
#>

foreach ($collision in $collisions) {
    $counter = 0
    $sortedCollision = $collision.Group | Sort-Object -Property id

        #Extract each employee from sortedCollision and increment username
        foreach ($employee in $sortedCollision){
            $counter++
            $usernameSuffix = "{0:D2}" -f $counter
            $newUsername = "$($employee.username)$usernameSuffix"
            $employee.username = $newUsername
    }
}
# The variable $employees now contains each employee object with resolved usernames

# ============================================================
# EMAIL GENERATION
# ============================================================
<# Each employee having the same username will have a new one using number iterations
Example :
id          : EMP0000
[...]
username    : mfurlan01
email       : mfurlan01@novera.fr
#>

foreach ($employee in $employees) {
    $email = "$($employee.username)@novera.fr"
    $employee | Add-Member -MemberType NoteProperty -Name "email" -Value $email
}

# ============================================================
# MANAGER DETECTION
# ============================================================
<#
Example :
id          : EMP3333
[...]
job_title   : Data Manager
[...]
is_manager  : True
#>

foreach ($employee in $employees) {
    if ($employee.job_title -in $roles.manager_job_titles) {
        $employee | Add-Member -MemberType NoteProperty -Name "is_manager" -Value $true
    }
    else {
        $employee | Add-Member -MemberType NoteProperty -Name "is_manager" -Value $false
    }
}

# ============================================================
# IT ADMIN DETECTION
# ============================================================
<#
Example :
id          : EMP9999
[...]
department  : IT
job_title   : Systems Administrator
[...]
is_it_admin : True
#>

foreach ($employee in $employees) {
    if ($employee.job_title -in $roles.it_admin_job_titles) {
        $employee | Add-Member -MemberType NoteProperty -Name "is_it_admin" -Value $true
    }
    else {
        $employee | Add-Member -MemberType NoteProperty -Name "is_it_admin" -Value $false
    }
}


# ============================================================
# DEPARTMENT GROUP GENERATION
# ============================================================
<#
Example :
id          : EMP0000
[...]
site        : Angoulême
department  : IT
[...]
dpt_grp     : GG_Angouleme_IT
#>
foreach ($employee in $employees){
    if ($employee.department -eq "Cybersecurity") {
        $dpt_grp = "GG_$($employee.department)"
    }
    else {
        $dpt_grp = "GG_$($employee.site)_$($employee.department)"
    }
    $employee | Add-Member -MemberType NoteProperty -Name "dpt_grp" -Value $dpt_grp
}

# ============================================================
# MANAGER GROUP GENERATION
# ============================================================
<#
Example :
id          : EMP3333
[...]
site        : Bordeaux
department  : Data
job_title   : Data Manager
[...]
is_manager  : True
[...]
dpt_grp     : GG_Bordeaux_Data
mgmt_grp    : GG_Bordeaux_Data_Managers
#>
foreach ($employee in $employees){
    if ($employee.is_manager -eq $true) {
        $mgmt_grp = "$($employee.dpt_grp)_Managers"
    }
    else {
        $mgmt_grp = $null
    }
    $employee | Add-Member -MemberType NoteProperty -Name "mgmt_grp" -Value $mgmt_grp
}


# ============================================================
# IT ADMIN GROUP GENERATION
# ============================================================
<#
Example :
id          : EMP9999
[...]
site        : Angoulême
department  : IT
job_title   : Systems Administrator
[...]
is_it_admin : True
dpt_grp     : GG_Angouleme_IT
admin_grp    : GG_Angouleme_IT_Admins
#>

foreach ($employee in $employees){
    if ($employee.is_it_admin -eq $true) {
        $admin_grp = "$($employee.dpt_grp)_Admins"
    }
    else {
        $admin_grp = $null
    }
    $employee | Add-Member -MemberType NoteProperty -Name "admin_grp" -Value $admin_grp
}

# ============================================================
# OU TARGET GENERATION
# ============================================================

$domain_dn = "DC=novera,DC=fr"

foreach ($employee in $employees) {
    $employee | Add-Member -MemberType NoteProperty -Name "ou_dn" -Value "OU=$($employee.department),OU=Users,OU=$($employee.site),$domain_dn"
}

# ============================================================
# ACTIVE DIRECTORY USER CREATION
# ============================================================
# ------------------------------------------------------------
# Verify that every target OU exists before creating users
# ------------------------------------------------------------
Import-Module ActiveDirectory -ErrorAction Stop

$targetOUs = $employees | Select-Object -ExpandProperty ou_dn -Unique

foreach ($ou in $targetOUs) {
    $null = Get-ADOrganizationalUnit -Identity $ou -ErrorAction Stop
    Write-Host "OU OK : $ou" -ForegroundColor Green
}



# ------------------------------------------------------------
# Add new user if it has not already been created
# ------------------------------------------------------------
$adusernames = Get-ADUser -Filter * | Select-Object -ExpandProperty SamAccountName

$createdUsers = [System.Collections.Generic.List[string]]::new()
$skippedUsers = [System.Collections.Generic.List[string]]::new()
$failedUsers = [System.Collections.Generic.List[string]]::new()

foreach ($employee in $employees) {
    if ($employee.username -in $adusernames) {
        $skippedUsers.Add($employee.username)
    }

    else {
        try {
            New-ADUser -SamAccountName $employee.username `
            -Name "$($employee.first_name) $($employee.last_name)" `
            -Path $employee.ou_dn `
            -GivenName $employee.first_name `
            -Surname $employee.last_name `
            -Title $employee.job_title `
            -Department $employee.department `
            -EmailAddress $employee.email `
            -Enabled $false `
            -ErrorAction Stop

            $createdUsers.Add($employee.username)
        }
        catch {
            $failedUsers.Add($employee.username)
            Write-Warning "$($employee.username) account creation error : $($_.Exception.Message)"
        }

    }
}

Write-Output "$($skippedUsers.count) already have an AD account"
Write-Output "List of skipped account : $($skippedUsers -join ', ')" ""
Write-Output "$($createdUsers.count) accounts have been created"
Write-Output "List of created account : $($createdUsers -join ', ')" ""
Write-Output "$($failedUsers.count) accounts creation failed"
Write-Output "List of failed account : $($failedUsers -join ', ')"

# ------------------------------------------------------------
# Add user to groups
# ------------------------------------------------------------
# Verify user is not already in the group

$failedDptGroupAdd = [System.Collections.Generic.List[string]]::new()
$failedMgmtGroupAdd = [System.Collections.Generic.List[string]]::new()
$failedAdminGroupAdd = [System.Collections.Generic.List[string]]::new()

foreach ($employee in $employees) {

    # Base department group
    $employee_dptGroup = Get-ADGroupMember -Identity $employee.dpt_grp | Select-Object -ExpandProperty SamAccountName
    if ($employee.username -notin $employee_dptGroup) {
        try {
            Add-ADGroupMember `
            -Identity $employee.dpt_grp `
            -Members $employee.username `
            -ErrorAction Stop
        }
        catch {
            $failedDptGroupAdd.Add($employee.username)
            Write-Warning "$($employee.username) group addition error : $($_.Exception.Message)"
        }
    }

    # If manager
    if ($null -ne $employee.mgmt_grp) {
        $employee_mgmtGroup = Get-ADGroupMember -Identity $employee.mgmt_grp | Select-Object -ExpandProperty SamAccountName
        if ($employee.username -notin $employee_mgmtGroup) {
            try {
                Add-ADGroupMember `
                -Identity $employee.mgmt_grp `
                -Members $employee.username `
                -ErrorAction Stop
            }
            catch {
                $failedMgmtGroupAdd.Add($employee.username)
                Write-Warning "$($employee.username) group addition error : $($_.Exception.Message)"
            }
        }
    }

    # If IT admin
    if ($null -ne $employee.admin_grp) {
        $employee_adminGroup = Get-ADGroupMember -Identity $employee.admin_grp | Select-Object -ExpandProperty SamAccountName
        if ($employee.username -notin $employee_adminGroup) {
            try {
                Add-ADGroupMember `
                -Identity $employee.admin_grp `
                -Members $employee.username `
                -ErrorAction Stop
            }
            catch {
                $failedAdminGroupAdd.Add($employee.username)
                Write-Warning "$($employee.username) group addition error : $($_.Exception.Message)"
            }
        }
    }
}

Write-Output "$($failedDptGroupAdd.count) account couldn't have been added to dpt group" ""
Write-Output "List of accounts with failed dpt_grp addition : $($failedDptGroupAdd -join ', ') "
Write-Output "$($failedMgmtGroupAdd.count) account couldn't have been added to mgmt group" ""
Write-Output "List of accounts with failed mgmt_grp addition : $($failedMgmtGroupAdd -join ', ') "
Write-Output "$($failedAdminGroupAdd.count) account couldn't have been added to admin group" ""
Write-Output "List of accounts with failed admin_grp addition : $($failedAdminGroupAdd -join ', ') "