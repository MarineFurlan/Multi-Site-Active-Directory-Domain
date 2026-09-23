# ============================================================
# DATA LOADING
# ============================================================

$json = Get-Content "./data/employees.json" -Encoding UTF8
$data = $json | ConvertFrom-Json

$roles_json = Get-Content "./data/roles.json" -Encoding UTF8
$roles = $roles_json | ConvertFrom-Json


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
mgmt_grp    : GG_Angouleme_IT_Admins
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