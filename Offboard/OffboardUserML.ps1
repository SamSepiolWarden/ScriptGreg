Connect-ExchangeOnline
# Function to get user input
function Get-UserToRemove {
    $userEmail = Read-Host "Enter the user's email address"
    return $userEmail
}

# Function to show spinner while processing
function Show-Spinner {
    param(
        [int]$CurrentItem,
        [int]$TotalItems,
        [string]$GroupName
    )
    $percentage = [math]::Round(($CurrentItem / $TotalItems) * 100)
    $progressBar = "[" + ("=" * [math]::Round($percentage/2)) + (" " * (50 - [math]::Round($percentage/2))) + "]"
    Write-Host "`rProcessing: $progressBar $percentage% - Current Group: $GroupName" -NoNewline
}

# Get the user email
$userToRemove = Get-UserToRemove

# Get all distribution groups with loading message
Write-Host "`nRetrieving all distribution groups..." -ForegroundColor Cyan
$allGroups = Get-DistributionGroup -ResultSize Unlimited
Write-Host "Found $($allGroups.Count) distribution groups to check`n" -ForegroundColor Cyan

# Initialize array to store groups where user is found
$groupsWithUser = @()
$currentGroup = 0
$totalGroups = $allGroups.Count

# Show initial progress bar
Write-Host "Progress: [                                                  ] 0%"

# Check each group for the user
foreach ($group in $allGroups) {
    $currentGroup++
    
    # Update progress bar
    $percentage = [math]::Round(($currentGroup / $totalGroups) * 100)
    $progressBar = "[" + ("=" * [math]::Round($percentage/2)) + (" " * (50 - [math]::Round($percentage/2))) + "]"
    Write-Host "`rProgress: $progressBar $percentage% - Checking: $($group.DisplayName)" -NoNewline
    
    try {
        $members = Get-DistributionGroupMember -Identity $group.DisplayName
        if ($members.PrimarySmtpAddress -contains $userToRemove) {
            $groupsWithUser += $group
            Write-Host "`nFound user in group: $($group.DisplayName)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "`nError checking group $($group.DisplayName): $_" -ForegroundColor Red
    }
}

# Clear the progress line and show final results
Write-Host "`n`nSearch completed!" -ForegroundColor Green

# If user is found in any groups, ask for confirmation to remove
if ($groupsWithUser.Count -gt 0) {
    Write-Host "`nUser found in $($groupsWithUser.Count) group(s):" -ForegroundColor Yellow
    $groupsWithUser | ForEach-Object { Write-Host "- $($_.DisplayName)" }
    
    $confirmation = Read-Host "`nDo you want to remove the user from these groups? (Y/N)"
    
    if ($confirmation -eq 'Y') {
        $currentGroup = 0
        $totalToRemove = $groupsWithUser.Count
        
        foreach ($group in $groupsWithUser) {
            $currentGroup++
            Write-Host "`rRemoving from groups: [$currentGroup/$totalToRemove] - Current: $($group.DisplayName)" -NoNewline
            
            try {
                Remove-DistributionGroupMember -Identity $group.DisplayName -Member $userToRemove -Confirm:$false
                Write-Host "`nSuccessfully removed from: $($group.DisplayName)" -ForegroundColor Green
            }
            catch {
                Write-Host "`nError removing from $($group.DisplayName): $_" -ForegroundColor Red
            }
        }
        Write-Host "`nRemoval process completed!" -ForegroundColor Green
    }
} else {
    Write-Host "User not found in any distribution groups" -ForegroundColor Yellow
}

# Final summary
Write-Host "`nOperation Summary:" -ForegroundColor Cyan
Write-Host "- Total groups checked: $totalGroups"
Write-Host "- Groups containing user: $($groupsWithUser.Count)"
if ($confirmation -eq 'Y') {
    Write-Host "- User has been removed from all found groups"}