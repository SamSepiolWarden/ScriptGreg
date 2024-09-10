$BLV = Get-BitLockerVolume -MountPoint “C:”

BackupToAAD-BitLockerKeyProtector -MountPoint “C:” -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
If($?)
{
(Write-Host "$BLV Key Successfully added to Azure" -ForegroundColor Green)
}
else
{
(Write-Host "$BLV Key Error Occurred" -ForegroundColor Red)
}