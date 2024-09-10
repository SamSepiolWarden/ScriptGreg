Connect-ExchangeOnline
$OutputFile = "C:\Users\GregorySemedo\Desktop\DL.csv"
$ML = Get-UnifiedGroup

$noLicenceData = @()
foreach ($group in $ML){
$Members = Get-UnifiedGroupLinks -Identity $group.Id -LinkType Member
if ($Members.Count -eq 0) {
$noLicenceData += [PSCustomObject]@{
"Nom du groupe:" = $Group.Name
"Adresse e-mail du groupe:" = $Group.PrimarySmtpAddress
"Filtre de réception:" = $Group.RecipientFilter
}
}
}
$noLicenceData | Export-Csv -Path $OutputFile -NoTypeInformation -Append -Encoding UTF8 -Force
Disconnect-ExchangeOnline