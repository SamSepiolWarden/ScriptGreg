Resume-Bitlocker -MountPoint "C:"
if($?) {
    Write-Host "Successfully resume Bitlocker."
$exitcode = 0
    
}
else {
    $exitcode = 1
    Write-Host "Failed to resume Bitlocker. Exit code: $exitCode."
}
exit $exitcode