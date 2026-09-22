$json = Get-Content "./data/employees.json" -Encoding UTF8
$data = $json | ConvertFrom-Json

# Usernames generation - Each employee-object has a "username" property
$employees = foreach ($employee in $data.employees) {
    $firstletter = $employee.first_name.Substring(0,1)
    $username = ($firstletter+$employee.last_name).ToLower().Normalize("FormD") -replace "\p{M}"
    $employee | Add-Member -MemberType NoteProperty -Name "username" -Value $username
    $employee
}

# Group employees by username and only ouput those with at least 1 collision
$collisions = $employees | Group-Object -Property username | Where-Object Count -GT 1


#### ==== TESTS ==== ####

# Do we have all the employees in the json file ?
Write-Output "COUNTING EMPLOYEES IN JSON FILE ..."
$targeted_employees_count = 98
$employees_count = $employees.Count
if ($targeted_employees_count -eq $employees_count) {
    Write-Output "Employees count: $employees_count" "Everyone is here" ""
}
else { Write-Output "Employees count: $employees_count" "The count is wrong" ""}

# Does every employee has an username ?
Write-Output "TESTING USERNAME PRESENCE FOR EACH EMPLOYEE ..."
$no_usernames = foreach ($employee in $employees) {
    if ($employee.username -eq $null) {
        Write-Output $employee.id
    }
}

if ($no_usernames -eq $null){
    Write-Output "Every employee has an username" ""
}
else {
Write-Output "List of employees without username: $no_usernames" ""
}

# Is there any duplicated username ?
Write-Output "TESTING USERNAME DUPLICATES ..."
if ($collisions -eq $null) {
    Write-Output "There is no duplicated username"
}
else {
    Write-Output "List of employees with the same username:" ""
    foreach ($collision in $collisions) {
        Write-Output "$($collision.Name):"
            foreach ($employee in $collision.Group) {
                Write-Output "  $($employee.id)"
            }
    }
}
