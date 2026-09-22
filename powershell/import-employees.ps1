# ============================================================
# DATA LOADING
# ============================================================

$json = Get-Content "./data/employees.json" -Encoding UTF8
$data = $json | ConvertFrom-Json



# ============================================================
# USERNAME GENERATION
# ============================================================
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

foreach ($collision in $collisions) {
    $counter = 0
    $sortedCollision = $collision.Group | Sort-Object -Property id

        #Extract each employee from sortedCollision and increment username
        foreach ($collidingEmployee in $sortedCollision){
            $counter++
            $usernameSuffix = "{0:D2}" -f $counter
            $newUsername = "$($collidingEmployee.username)$usernameSuffix"
            $collidingEmployee.username = $newUsername
    }
}


# ============================================================
# TESTS
# ============================================================
$failed_tests = 0

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
    Write-Output "[PASS] There is no duplicated username"
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

Write-Output "Failed test count : $failed_tests"
if ($failed_tests -gt 0){
    exit 1
}
else { exit 0 }