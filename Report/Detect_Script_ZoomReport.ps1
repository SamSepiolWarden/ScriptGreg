# Define possible Zoom executable paths
$programFilesPath = "C:\Program Files (x86)\Zoom\Zoom.exe"
$appDataPath = "$env:APPDATA\Zoom\bin\Zoom.exe"

# Initialize $zoomVersion as empty
$zoomVersion = ""

# Fallback to getting the version from Zoom.exe in Program Files if winget failed
if (-not $zoomVersion -and (Test-Path $programFilesPath)) {
    $zoomExe = (Get-Command $programFilesPath).FileVersionInfo.FileVersion
    
    $zoomVersion = $zoomExe
    
}

# Fallback to getting the version from Zoom.exe in AppData if not found in Program Files
if (-not $zoomVersion -and (Test-Path $appDataPath)) {
    $zoomExe = (Get-Command $appDataPath).FileVersionInfo.FileVersion
    
    $zoomVersion = $zoomExe
    
}

# Output the Zoom version or a message if not found
if ($zoomVersion) {
    Write-Output "Zoom version: $zoomVersion"
} else {
    Write-Output "Zoom is not installed or could not detect version."
}
