$json = Get-Content "./data/employees.json" -Encoding UTF8
$data = $json | ConvertFrom-Json

# Usernames generation
$usernames = foreach ($employee in $data.employees) {
    $firstletter = $employee.first_name.Substring(0,1)
    $username = ($firstletter+$employee.last_name).ToLower().Normalize("FormD") -replace "\p{M}"
    $username
}

# Usernames collision enumeration
$collisions = $usernames | Group-Object -NoElement | Where-Object Count -GT 1
Write-Output $collisions