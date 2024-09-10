$Users = Get-LocalUser | Select-Object -Property Name, Enabled
$Output = @()

foreach ($User in $Users) {
    $Output += "The User: $($User.Name) | Status: $($User.Enabled)"
}

# Output all at once
$Output | ForEach-Object { Write-Output $_ }
