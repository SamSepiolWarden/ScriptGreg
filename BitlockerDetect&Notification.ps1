$Bitlocker = Get-BitLockerVolume -MountPoint "C:" | Select-Object -Property ProtectionStatus
$ExitCode = 0
if ($Bitlocker.ProtectionStatus -eq "On") {
    $ExitCode = 0
    Write-Output "Bitlocker est active sur le disque !" -ForegroundColor Green
} else {
    $ExitCode = 1
    Write-Output "Bitlocker n'est pas active sur le disque !" -ForegroundColor Cyan
}
if ($ExitCode -eq 1){
Write-Output "Bitlocker protection status : $Bitlocker.ProtectionStatus"
}
exit $ExitCode

