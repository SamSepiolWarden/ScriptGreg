# Define the paths using PowerShell's environment variable syntax
$Libwebp = Join-Path $env:LOCALAPPDATA "learnpluse\screenpresso\libwebp_x64.dll"
$Libwebp2 = "C:\Program Files\Learnpulse\Screenpresso\libwebp_x64.dll"
$Libwebp3 = "C:\Windows\Installer\Razer\Installer\App\libwebp_x64.dll"
$Libwebp4 = "C:\Windows\Installer\Razer\Installer\App\libwebp_x86.dll"
# Check if the file exists in the first location and remove it
if (Test-Path $Libwebp) {
    Write-Output "Libwebp is installed on the disk at $Libwebp. Removing..."
    Remove-Item $Libwebp -Force
    Write-Output "File removed from $Libwebp."
}

# Check if the file exists in the second location and remove it
if (Test-Path $Libwebp2) {
    Write-Output "Libwebp is installed on the disk at $Libwebp2. Removing..."
    Remove-Item $Libwebp2 -Force
    Write-Output "File removed from $Libwebp2."
}

if (Test-Path $Libwebp3) {
    Write-Output "Libwebp is installed on the disk at $Libwebp3. Removing..."
    Remove-Item $Libwebp3 -Force
    Write-Output "File removed from $Libwebp3."
}

if (Test-Path $Libwebp4) {
    Write-Output "Libwebp is installed on the disk at $Libwebp4. Removing..."
    Remove-Item $Libwebp4 -Force
    Write-Output "File removed from $Libwebp4."
}
# If no file was found at either location, output that information
if (-not (Test-Path $Libwebp) -and -not (Test-Path $Libwebp2) -and -not (Test-Path $Libwebp3) -and -not (Test-Path $Libwebp4)) {
    Write-Output "Libwebp is not installed on the disk at either location."
}
