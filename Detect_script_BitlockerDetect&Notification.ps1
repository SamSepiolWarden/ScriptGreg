$Bitlocker = Get-BitLockerVolume -MountPoint "C:" | Select-Object -Property ProtectionStatus
$ExitCode = 0
if ($Bitlocker.ProtectionStatus -eq "On") {
    $ExitCode = 0
    Write-Output "Bitlocker est active sur le disque !"
} else {
    $ExitCode = 1
    Write-Output "Bitlocker n'est pas active sur le disque !"
}
if ($ExitCode -eq 1){
Write-Output $Bitlocker 
}
exit $ExitCode

