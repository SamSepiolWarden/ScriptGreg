Connect-MgGraph -Scopes "UserAuthenticationMethod.ReadWrite.All"

$AskUser = "Y"

while ($AskUser -ne "N") {
    # User upn prompt
    $UPN = Read-Host -Prompt "Enter the UPN of the user to get the information"

    $properties = @{}
    
    $properties.isUsableOnce = $false
    $Date = Get-Date
    $properties.startdateTime = $Date
    $properties.LifetimeInMinutes = 21600
    $propertiesJson = $properties | ConvertTo-Json
    $hash = @{}

    $AskToAdd = Read-Host -Prompt "Do you want to add a Tap to $UPN ? (Y/N)"
    if ($AskToAdd -eq "Y") {
        $AddTap = New-MgUserAuthenticationTemporaryAccessPassMethod -UserId $UPN -BodyParameter $propertiesJson
        if($null -ne $AddTap){
            $AddTap
            Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $UPN
            $Hash.add($UPN, $AddTap.TemporaryAccessPass)
            $hash.GetEnumerator() | Select-Object -Property @{N="$UPN";E={$_.Key}}, @{N='Temporary Access Pass';E={$_.Value}}
        }
        else {
            Write-Host "Error while adding Tap"
        }
    }
    else {
        Write-Host "No Tap added"
        Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $UPN
    }
    $AskUser = Read-Host -Prompt "Do you want to add another Tap ? (Y/N)"
}
if($AskUser -eq "N"){
    Write-Host "End of the Tap addition" -ForegroundColor Cyan
    Disconnect-MgGraph
}
