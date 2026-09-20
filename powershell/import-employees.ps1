$json = Get-Content "./data/employees.json" -Encoding UTF8
$data = $json | ConvertFrom-Json

# Generate username
foreach ($employee in $data.employees) {
    $firstletter = $employee.first_name.Substring(0,1)
    $username = ($firstletter+$employee.last_name).ToLower().Normalize("FormD") -replace "\p{M}"
    Write-Output "$($employee.id) - $($employee.first_name) $($employee.last_name) - $($employee.site) - $($employee.department) - $($username)"
}
