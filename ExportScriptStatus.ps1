# Get execution policy for all scopes
$executionPolicies = Get-ExecutionPolicy -List

# Prepare the output content
$outputContent = @()
$outputContent += "Execution Policy Status for User: $($env:USERNAME)"
$outputContent += "Date: $(Get-Date)"
$outputContent += ""
$outputContent += "Scope            ExecutionPolicy"
$outputContent += "-----            ---------------"

foreach ($policy in $executionPolicies) {
    $outputContent += "{0,-16} {1}" -f $policy.Scope, $policy.ExecutionPolicy
}

# Output the results to the console
$outputContent | Out-String

# Notify the user in the output
$outputContent | ForEach-Object { Write-Output $_ }
