# Execution of script to extract $employees
. "./scripts/import-employees.ps1"

$failed_tests = 0



# ========================================================================================================
# DATA INTEGRITY
# Does the data exist and is it usable ?
# ========================================================================================================
Write-Output "`n========== DATA INTEGRITY =========="
# ------------------------------------------------------------
# Employee count
# ------------------------------------------------------------
$targeted_employees_count = 98
$employees_count = $employees.Count
if ($targeted_employees_count -eq $employees_count) {
    Write-Output "`n[PASS] Employees count: $employees_count / $targeted_employees_count"
}
else {
    Write-Output "`n[FAIL] Employees count: $employees_count / $targeted_employees_count"
    $failed_tests++
}


# ------------------------------------------------------------
# Username presence
# ------------------------------------------------------------
$no_usernames = foreach ($employee in $employees) {
    if ($employee.username -eq $null) {
        Write-Output $employee.id
    }
}

if ($no_usernames -eq $null){
    Write-Output "[PASS] Username presence"
}
else {
Write-Output "[FAIL] Employees without username: $no_usernames"
$failed_tests++
}

# ------------------------------------------------------------
# Username duplicates
# ------------------------------------------------------------
$remaining_collisions = $employees |
    Group-Object -Property username |
    Where-Object Count -GT 1

if ($remaining_collisions -eq $null) {
    Write-Output "[PASS] Username uniqueness"
}
else {
    Write-Output "[FAIL] Duplicate usernames:"
    foreach ($collision in $remaining_collisions) {
        Write-Output "$($collision.Name):"
            foreach ($employee in $collision.Group) {
                Write-Output "  $($employee.id)"
            }
    }
    $failed_tests++
}

# ------------------------------------------------------------
# Email presence
# ------------------------------------------------------------
$no_emails = foreach ($employee in $employees) {
    if ($employee.email -eq $null) {
        Write-Output $employee.id
    }
}

if ($no_emails -eq $null){
    Write-Output "[PASS] Email presence"
}
else {
Write-Output "[FAIL] Employees without email: $no_emails"
$failed_tests++
}

# ------------------------------------------------------------
# OU target presence
# ------------------------------------------------------------
$no_ou_targets = foreach ($employee in $employees) {
    if ($employee.ou_dn -eq $null) {
        Write-Output $employee.id
    }
}

if ($no_ou_targets -eq $null) {
    Write-Output "[PASS] OU target presence"
}
else {
    Write-Output "[FAIL] Employees without an OU target: $no_ou_targets"
    $failed_tests++
}


# ------------------------------------------------------------
# Manager reference validity
# Does the manager attribute reference an existing employee ?
# ------------------------------------------------------------
$invalid_manager = foreach ($employee in $employees) {
    if (($employee.manager -ne $null) -and ($employee.manager -notin $employees.id )) {
        Write-Output $employee.id
    }
}

if ($invalid_manager -eq $null) {
    Write-Output "[PASS] Manager references are valid"
}
else {
    Write-Output "[FAIL] Invalid manager references: $invalid_manager"
    $failed_tests++
}

# ------------------------------------------------------------
# Reference values validity
# ------------------------------------------------------------
$invalid_references = foreach ($employee in $employees) {

    # Sites
    if ($employee.site -notin $references.sites) {
        Write-Output "Wrong site : $($employee.id)"
    }

    # Departments
    if ($employee.department -notin $references.departments) {
        Write-Output "Wrong department : $($employee.id)"
    }

}

if ($invalid_references -eq $null) {
    Write-Output "[PASS] Site and department references are valid"
}
else {
    Write-Output "[FAIL] Invalid site/department references: $($invalid_references -join ", ")"
    $failed_tests++
}




# ========================================================================================================
# STRUCTURE / TYPES
# Does the data have the correct type
# ========================================================================================================
Write-Output "`n========== STRUCTURE / TYPES =========="

$boolean_attributes= @(
    "is_manager"
    "is_it_admin"
)

$string_attributes= @(
    "id"
    "first_name"
    "last_name"
    "site"
    "department"
    "job_title"
    "username"
    "email"
    "ou_dn"
    "dpt_grp"
)

$string_or_null_attributes= @(
    "manager"
    "mgmt_grp"
    "admin_grp"
)

$invalid_types = foreach ($employee in $employees) {
# ------------------------------------------------------------
# Boolean values
# ------------------------------------------------------------
    foreach ($boolean_attribute in $boolean_attributes){
        if ($employee.$boolean_attribute -isnot [bool]) {
            Write-Output "`nWrong $boolean_attribute value type : $($employee.id) $($employee.username)"
        }
    }

# ------------------------------------------------------------
# String values
# ------------------------------------------------------------
    foreach ($string_attribute in $string_attributes){
        if ($employee.$string_attribute -isnot [string]) {
            Write-Output "`nWrong $string_attribute value type : $($employee.id) $($employee.username)"
        }
    }

# ------------------------------------------------------------
# Boolean or string values
# ------------------------------------------------------------
   foreach ($string_or_null_attribute in $string_or_null_attributes){
        if (-not (($employee.$string_or_null_attribute -is [string]) -or ($employee.$string_or_null_attribute -eq $null))) {
            Write-Output "`nWrong $string_or_null_attribute value type : $($employee.id) $($employee.username)"
        }
    }
}

if ($invalid_types -eq $null) {
    Write-Output "`n[PASS] Attribute types are valid"
}
else {
    Write-Output "`n[FAIL] Attributes with invalid types: $($invalid_types -join ", ")"
    $failed_tests++
}




# ========================================================================================================
# JOB RULES
# Does the data follows Novera rules ?
# ========================================================================================================
Write-Output "`n========== JOB RULES =========="

# ------------------------------------------------------------
# Manager detection
# ------------------------------------------------------------
$managers = $employees | Where-Object -Property job_title -in $roles.manager_job_titles
$non_managers = $employees |  Where-Object -Property job_title -notin $roles.manager_job_titles

$invalid_is_manager_att = foreach ($employee in $employees) {
    if ( (($employee -in $managers) -and ($employee.is_manager -ne $true)) -or (($employee -in $non_managers) -and ($employee.is_manager -ne $false)) ) {
        Write-Output $employee.id
    }
}

if ($invalid_is_manager_att -ne $null) {
   Write-Output "`n[FAIL] Invalid is_manager values: $invalid_is_manager_att"
   $failed_tests++
}
else {
    Write-Output "`n[PASS] is_manager matches job title"
}


# ------------------------------------------------------------
# IT admin detection
# ------------------------------------------------------------
$it_admins = $employees | Where-Object -Property job_title -in $roles.it_admin_job_titles

$invalid_is_admin_att = foreach ($employee in $employees) {
    if ( (($employee -in $it_admins) -and ($employee.is_it_admin -ne $true)) -or (($employee -notin $it_admins) -and ($employee.is_it_admin -ne $false)) ) {
        Write-Output $employee.id
    }
}

if ($invalid_is_admin_att -ne $null) {
   Write-Output "[FAIL] Invalid is_it_admin values: $invalid_is_admin_att"
   $failed_tests++
}
else {
    Write-Output "[PASS] is_it_admin matches job title"
}



# ------------------------------------------------------------
# mgmt_grp and admin_grp nullability
# ------------------------------------------------------------
$invalid_null_group = foreach($employee in $employees){

    # mgmt_grp attribute
    if(
        (($employee.is_manager -eq $true) -and ($employee.mgmt_grp -eq $null)) -or
        (($employee.is_manager -eq $false) -and ($employee.mgmt_grp -ne $null))
    ) {
        Write-Output "Wrong mgmt_grp value : $($employee.id)"
    }

    # admin_grp attribute
    if(
        (($employee.is_it_admin -eq $true) -and ($employee.admin_grp -eq $null)) -or
        (($employee.is_it_admin -eq $false) -and ($employee.admin_grp -ne $null))
    ) {
        Write-Output "Wrong admin_grp value : $($employee.id)"
    }
}

if ($invalid_null_group -ne $null) {
    Write-Output "[FAIL] Invalid manager/admin group values: $($invalid_null_group -join ", ")"
    $failed_tests++
}
else {
    Write-Output "[PASS] Manager/admin group nullability"
}






# ========================================================================================================
# DATA COHERENCE
# Does every data tell the same story ?
# ========================================================================================================
Write-Output "`n========== DATA COHERENCE =========="
# ------------------------------------------------------------
# Email consistency
# ------------------------------------------------------------
$invalid_emails = foreach ($employee in $employees){
    if($employee.email -ne "$($employee.username)@novera.fr" ) {
        Write-Output "`n$($employee.id) - $($employee.username) - $($employee.email) | "
    }
}

if ($invalid_emails -eq $null) {
       Write-Output "`n[PASS] Email matches username"
    }
else {
        Write-Output "`n[FAIL] Emails inconsistent with usernames: $($invalid_emails -join "; ")"
        $failed_tests++
}

# ------------------------------------------------------------
# Manager group consistency
# ------------------------------------------------------------
$invalid_mgmt_grp = foreach ($employee in $employees) {

    $expected_mgmt_grp = "$($employee.dpt_grp)_Managers"

    if ($employee.is_manager -eq $true) {
        if ($employee.mgmt_grp -ne $expected_mgmt_grp) {
            Write-Output $employee.id
        }
    }
    else {
        if ($employee.mgmt_grp -ne $null) {
            Write-Output $employee.id
        }
    }
}

if ($invalid_mgmt_grp -ne $null) {
    Write-Output "[FAIL] Invalid mgmt_grp values: $invalid_mgmt_grp"
    $failed_tests++
}
else {
    Write-Output "[PASS] Management group naming"
}


# ------------------------------------------------------------
# IT Admin group consistency
# ------------------------------------------------------------
$invalid_admin_grp = foreach ($employee in $employees) {

    $expected_admin_grp = "$($employee.dpt_grp)_Admins"

    if ($employee.is_it_admin -eq $true) {
        if ($employee.admin_grp -ne $expected_admin_grp) {
            Write-Output $employee.id
        }
    }
    else {
        if ($employee.admin_grp -ne $null) {
            Write-Output $employee.id
        }
    }
}

if ($invalid_admin_grp -ne $null) {
    Write-Output "[FAIL] Invalid admin_grp values: $invalid_admin_grp"
    $failed_tests++
}
else {
    Write-Output "[PASS] IT admin group naming"
}

# ------------------------------------------------------------
# Department group consistency
# ------------------------------------------------------------
$invalid_dpt_grp = foreach ($employee in $employees) {
    if ($employee.department -eq "Cybersecurity") {
        if ($employee.dpt_grp -ne "GG_$($employee.department)") {
            Write-Output $employee.id
        }
    }
    else {
        if ($employee.dpt_grp -ne "GG_$($employee.site)_$($employee.department)") {
            Write-Output $employee.id
        }
    }
}

if ($invalid_dpt_grp -ne $null) {
   Write-Output "[FAIL] Invalid dpt_grp values: $invalid_dpt_grp"
   $failed_tests++
}
else {
    Write-Output "[PASS] Department group naming"
}



# ========================================================================================================
# TESTS OVERVIEW
# ========================================================================================================
Write-Output "`n========== TEST SUMMARY =========="
Write-Output "`nFailed tests: $failed_tests"
if ($failed_tests -gt 0){
    exit 1
}
else { exit 0 }
