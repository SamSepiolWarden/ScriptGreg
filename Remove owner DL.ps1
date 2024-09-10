Connect-ExchangeOnline
$Admin = Read-Host -Prompt "Enter the mail adress to remove"
$Department = Read-Host -Prompt "Enter the Department"
$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Department.csv"
ForEach ($DL in $DLs) {
     Set-DistributionGroup -Identity $DL.DL -BypassSecurityGroupManagerCheck -ManagedBy @{Remove=$Admin}       
       If($?)
       {
        Write-Host $Admin Succesfully removed -ForegroundColor Green
       } 
       Else
       {
        Write-Host $Admin Could not be removed -ErrorAction -ForegroundColor Red
       }
}
Disconnect-ExchangeOnline