$Libwebp = "$env:LOCALAPPDATA\learnpulse\screenpresso\libwebp_x64.dll"
$Libwebp2 = "c:\program files\learnpulse\screenpresso\libwebp_x64.dll"
$Libwebp3 = "c:\windows\installer\razer\installer\app\libwebp_x64.dll"
$Libwebp4 = "c:\windows\installer\razer\installer\app\libwebp_x86.dll"
If((Test-Path $Libwebp) -or (Test-Path $Libwebp2) -or (Test-Path $Libwebp3) -or (Test-Path $Libwebp4)) {
    write-output "Libwebp est installe sur le disque !"
    $ExitCode = exit 1
}
else {
    write-output "Libwebp n'est pas installe sur le disque !"
    $ExitCode = exit 0
}
exit $ExitCode