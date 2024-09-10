Winget install Microsoft.PCManager.Beta --Disable-Interactivity --accept-package-agreements --silent 

if ($?) {
    Write-Output "PC Manager installed successfully"
} 
else {
    Write-Output "PC Manager installation failed"}