# Define the paths

$Git = "C:\Program Files\Git\git-cmd.exe"

# Check if either path exists
If (Test-Path $Git) {
    Write-Output " est installé sur le disque !"
    exit 1
} else {
    Write-Output "Libwebp n'est pas installé sur le disque !"
    exit 0
}
