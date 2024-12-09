
$glpiAgentUrl = "http://localhost:62354/now"

# Send a request to the GLPI agent to force the inventory
try {
    # Perform the web request silently
    $response = Invoke-WebRequest -Uri $glpiAgentUrl -ErrorAction SilentlyContinue
} catch {
    # If an error occurs, silently handle it (no output)
    $null = $_.Exception.Message
}

# Check the response and set the exit code accordingly
if ($response.StatusCode -eq 200) {
    $ExitCode = 0
    Write-Output "Inventory request sent successfully"
} else {
    $ExitCode = 1
    Write-Output "Failed to send inventory request"
}

# Output the exit code to the console
Write-Host "Exit Code: $ExitCode"
Write-Host "$response"

# Exit the script with the appropriate exit code (as an integer)
exit $ExitCode

