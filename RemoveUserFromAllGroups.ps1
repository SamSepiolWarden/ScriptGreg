Connect-AzureAD

$User = Read-Host -Prompt "Enter the user to remove from groups"

$UserObjectId = (Get-AzureADUser -SearchString $User).ObjectId

$Groups = Get-AzureADUserMembership -ObjectId $UserObjectId

foreach($Group in $Groups)
{
    $GroupDetails = Get-AzureADGroup -ObjectId $Group.ObjectId | Select-Object DisplayName, SecurityEnabled, MailEnabled
    if($GroupDetails.SecurityEnabled -eq $true)
    {
        Remove-AzureADGroupMember -ObjectId $Group.ObjectId -MemberId $UserObjectId
        Write-Host "User $User removed from group $GroupDetails.DisplayName" -ForegroundColor Green
    }
    else
    {
            Write-Host "User $User not removed from group $GroupDetails.DisplayName because it is not a security group" -ForegroundColor Red
    }
    if($GroupDetails.SecurityEnabled -eq $false -and $GroupDetails.MailEnabled -eq $true)
    {
        Remove-AzureADGroup -ObjectId $Group.ObjectId
        Write-Host "Group $GroupDetails.DisplayName removed" -ForegroundColor Green
    }
    else
    {
        Write-Host "Group $GroupDetails.DisplayName not removed because it is not an MS365 Group" -ForegroundColor Red
    }
}
Connect-ExchangeOnline

$ALLDL = Get-DistributionGroup -ResultSize Unlimited

foreach($DL in $ALLDL)
{
    $DLMembers = Get-DistributionGroupMember $DL.Identity
    if($DLMembers -contains $User)
    {
        Remove-DistributionGroupMember -Identity $DL.Identity -Member $User
        Write-Host "User $User removed from group $DL.Identity" -ForegroundColor Green
    }
    else
    {
        Write-Host "User $User not removed from group $DL.Identity because it is not a member" -ForegroundColor Red
    }
}
Disconnect-AzureAD
Disconnect-ExchangeOnline
