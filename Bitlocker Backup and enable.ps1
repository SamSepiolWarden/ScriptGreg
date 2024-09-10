$OSDrive = $env:SystemDrive
$checkifexist = (Get-BitLockerVolume -MountPoint $OSDrive).KeyProtector | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'}
 if($checkifexist) {
Write-host "Bitlocker is already enabled and have recoverykey"
}
else{
 
$bdeProtect = Get-BitLockerVolume $OSDrive | Select-Object -Property VolumeStatus
if ($bdeProtect.VolumeStatus -eq "FullyDecrypted")
    {
    # Enable Bitlocker using TPM
    Enable-BitLocker -MountPoint $OSDrive  -TpmProtector -ErrorAction Continue
    Enable-BitLocker -MountPoint $OSDrive  -RecoveryPasswordProtector
 
    }
}    
$cmdName = "BackupToAAD-BitLockerKeyProtector"
if (Get-Command $cmdName -ErrorAction SilentlyContinue)
{

#BackupToAAD-BitLockerKeyProtector commandlet exists
$BLK = (Get-BitLockerVolume -MountPoint $OSDrive).KeyProtector | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'}
if ($BLK.count -gt 1){
Write-Host "There are multiple recovery keys, will backup key number 1 to AzureAD"
$key = $BLK[0]
BackupToAAD-BitLockerKeyProtector -MountPoint $OSDrive -KeyProtectorId $key.KeyProtectorId
}
 
else {
Write-Host "There are only one recovery key, will start to backup to AzureAD"
BackupToAAD-BitLockerKeyProtector -MountPoint $OSDrive -KeyProtectorId $BLK.KeyProtectorId
}}