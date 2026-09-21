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
$collisions = $employees| Group-Object -Property username -NoElement | Where-Object Count -GT 1
Write-Output $collisions

Write-Output $employees | Where-Object username -eq "epetit"