Connect-ExchangeOnline

$DynamicMailbox = Read-Host -Prompt "Enter the name of the Dynamic Distribution Group"

$DynamicMailbox1 = Get-DynamicDistributionGroup -Identity $DynamicMailbox | Select-Object -ExpandProperty RequireSenderAuthenticationEnabled
Write-Host $DynamicMailbox1
if($DynamicMailbox1 -eq $false)
{
    Write-Host "The Dynamic Distribution Group $DynamicMailbox is already Send/Receive externally" 
    $ChangeDynDist = Read-Host -Prompt "Do you want to change it to internal? (Y/N)"
    if ($ChangeDynDist -eq "Y") {
        Set-DynamicDistributionGroup -Identity $DynamicMailbox -RequireSenderAuthenticationEnabled $true
    }
    else {
        Write-Host "The Dynamic Distribution Group $DynamicMailbox is still configured to send externally"
    }
}
else
{
    Set-DynamicDistributionGroup -Identity $DynamicMailbox -RequireSenderAuthenticationEnabled $false
    Write-Host "The Dynamic Distribution Group is now configured to send externally"
}
Disconnect-ExchangeOnline