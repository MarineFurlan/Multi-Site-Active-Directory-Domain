# Execution of script to extract $employees
. "./scripts/import-employees.ps1"

$failed_tests = 0

# ========================================================================================================
# DATA INTEGRITY
# Does the data exist and is it usable ?
# ========================================================================================================
# ------------------------------------------------------------
# Employee count
# ------------------------------------------------------------
Write-Output "COUNTING EMPLOYEES IN JSON FILE ..."
$targeted_employees_count = 98
$employees_count = $employees.Count
if ($targeted_employees_count -eq $employees_count) {
    Write-Output "[PASS] Employees count: $employees_count" ""
}
else {
    Write-Output "[FAIL] Employees count: $employees_count" ""
    $failed_tests++
}


# ------------------------------------------------------------
# Username presence
# ------------------------------------------------------------
Write-Output "TESTING USERNAME PRESENCE FOR EACH EMPLOYEE ..."
$no_usernames = foreach ($employee in $employees) {
    if ($employee.username -eq $null) {
        Write-Output $employee.id
    }
}

if ($no_usernames -eq $null){
    Write-Output "[PASS] Every employee has a username" ""
}
else {
Write-Output "[FAIL] List of employees without username: $no_usernames" ""
$failed_tests++
}

# ------------------------------------------------------------
# Username duplicates
# ------------------------------------------------------------
Write-Output "TESTING USERNAME DUPLICATES ..."

$remaining_collisions = $employees |
    Group-Object -Property username |
    Where-Object Count -GT 1

if ($remaining_collisions -eq $null) {
    Write-Output "[PASS] There is no duplicated username" ""
}
else {
    Write-Output "[FAIL] List of employees with the same username:" ""
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
Write-Output "TESTING EMAIL PRESENCE FOR EACH EMPLOYEE ..."
$no_emails = foreach ($employee in $employees) {
    if ($employee.email -eq $null) {
        Write-Output $employee.id
    }
}

if ($no_emails -eq $null){
    Write-Output "[PASS] Every employee has an email" ""
}
else {
Write-Output "[FAIL] List of employees without email: $no_emails" ""
$failed_tests++
}

# ------------------------------------------------------------
# OU target presence
# ------------------------------------------------------------
Write-Output "TESTING OU TARGET FOR EACH EMPLOYEE ..."

$no_ou_targets = foreach ($employee in $employees) {
    if ($employee.ou_dn -eq $null) {
        Write-Output $employee.id
    }
}

if ($no_ou_targets -eq $null) {
    Write-Output "[PASS] Every employee has an OU target" ""
}
else {
    Write-Output "[FAIL] List of employees without an OU target: $no_ou_targets" ""
    $failed_tests++
}





# ========================================================================================================
# STRUCTURE / TYPES
# Does the data have the correct type
# ========================================================================================================




# ========================================================================================================
# JOB RULES
# Does the data follows Novera rules ?
# ========================================================================================================

# ------------------------------------------------------------
# Manager detection
# ------------------------------------------------------------
Write-Output "TESTING IS_MANAGER ATTRIBUTION FOR EACH EMPLOYEE ..."

$managers = $employees | Where-Object -Property job_title -in $roles.manager_job_titles
$non_managers = $employees |  Where-Object -Property job_title -notin $roles.manager_job_titles

$invalid_is_manager_att = foreach ($employee in $employees) {
    if ( (($employee -in $managers) -and ($employee.is_manager -ne $true)) -or (($employee -in $non_managers) -and ($employee.is_manager -ne $false)) ) {
        Write-Output $employee.id
    }
}

if ($invalid_is_manager_att -ne $null) {
   Write-Output "[FAIL] List of employees without a valid is_manager attribute: $invalid_is_manager_att" ""
   $failed_tests++
}
else {
    Write-Output "[PASS] Every employee has a valid is_manager attribute" ""
}
 #>


# ------------------------------------------------------------
# IT admin detection
# ------------------------------------------------------------
Write-Output "TESTING IS_IT_ADMIN ATTRIBUTION FOR EACH EMPLOYEE ..."

$it_admins = $employees | Where-Object -Property job_title -in $roles.it_admin_job_titles

$invalid_is_admin_att = foreach ($employee in $employees) {
    if ( (($employee -in $it_admins) -and ($employee.is_it_admin -ne $true)) -or (($employee -notin $it_admins) -and ($employee.is_it_admin -ne $false)) ) {
        Write-Output $employee.id
    }
}

if ($invalid_is_admin_att -ne $null) {
   Write-Output "[FAIL] List of employees without a valid is_it_admin attribute: $invalid_is_admin_att" ""
   $failed_tests++
}
else {
    Write-Output "[PASS] Every employee has a valid is_it_admin attribute" ""
}


# ------------------------------------------------------------
# Department group consistency
# ------------------------------------------------------------
Write-Output "TESTING DEPARTMENT GROUP CONSISTENCY FOR EACH EMPLOYEE ..."

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
   Write-Output "[FAIL] List of employees without a valid dpt_grp attribute: $invalid_dpt_grp" ""
   $failed_tests++
}
else {
    Write-Output "[PASS] Every employee has a valid dpt_grp attribute" ""
}


# ------------------------------------------------------------
# Manager group consistency
# ------------------------------------------------------------
Write-Output "TESTING MANAGEMENT GROUP CONSISTENCY FOR EACH EMPLOYEE ..."

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
    Write-Output "[FAIL] List of employees without a valid mgmt_grp attribute: $invalid_mgmt_grp" ""
    $failed_tests++
}
else {
    Write-Output "[PASS] Every employee has a valid mgmt_grp attribute" ""
}


# ------------------------------------------------------------
# IT Admin group consistency
# ------------------------------------------------------------
Write-Output "TESTING IT ADMIN GROUP CONSISTENCY FOR EACH EMPLOYEE ..."

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
    Write-Output "[FAIL] List of it admins without a valid admin_grp attribute: $invalid_admin_grp" ""
    $failed_tests++
}
else {
    Write-Output "[PASS] Every employee has a valid admin_grp attribute" ""
}




# ========================================================================================================
# DATA COHERENCE
# Does every data tell the same story ?
# ========================================================================================================
# ------------------------------------------------------------
# Email consistency
# ------------------------------------------------------------
Write-Output "TESTING EMAIL CONSISTENCY FOR EACH EMPLOYEE ..."
$invalid_emails = foreach ($employee in $employees){
    if($employee.email -ne "$($employee.username)@novera.fr" ) {
        Write-Output "$($employee.id) - $($employee.username) - $($employee.email) | "
    }
}

if ($invalid_emails -eq $null) {
       Write-Output "[PASS] Every employee has a valid email" ""
    }
else {
        Write-Output "[FAIL] List of employees without a valid email: $invalid_emails" ""
        $failed_tests++
}



# ========================================================================================================
# EXPECTED RESULTS
# ========================================================================================================



# ========================================================================================================
# TeESTS OVERVIEW
# ========================================================================================================
Write-Output "Failed test count : $failed_tests"
if ($failed_tests -gt 0){
    exit 1
}
else { exit 0 }
#>