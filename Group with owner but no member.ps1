Connect-AzureAD

$groups = Get-AzureADGroup | Where-Object {$_.Owners.Count -gt 0}

Foreach ($group in $groups){
    $members = Get-AzureADGroupMember -ObjectId $group.ObjectId
    if ($members.Count -eq 0) {
        Write-Output $group.DisplayName
    }
}
