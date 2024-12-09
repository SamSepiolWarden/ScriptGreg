Connect-ExchangeOnline
$BadGroups = 0
$GoodGroups = 0
$Groups = Get-DistributionGroup
 ForEach ($G in $Groups) {
    If ($G.ManagedBy -Ne $Null) 
       {
       $GoodGroups = $GoodGroups + 1
       }
    Else
       {
       Write-Host "Warning! The" $G.DisplayName "has no owners"
       $BadGroups = $BadGroups + 1 
       }
  }
Write-Host $GoodGroups "groups are OK but" $BadGroups "groups lack owners"