# Get execution policy for the MachinePolicy scope
$executionPolicy = Get-ExecutionPolicy -Scope CurrentUser

# Prepare the output content
$outputContent = @()
$outputContent += "Execution Policy Status for User: $($env:USERNAME)"
$outputContent += "Date: $(Get-Date)"
$outputContent += ""
$outputContent += "Scope            ExecutionPolicy"
$outputContent += "-----            ---------------"
$outputContent += ("{0,-16} {1}" -f "CurrentUser", $executionPolicy)

# Output the results to the console
$outputContent | ForEach-Object { Write-Output $_ }


