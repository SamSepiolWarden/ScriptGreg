# Directory containing files to upload
$sourceDir = "D:\"
# Your bucket name
$bucketName = "backup-greg"

# Get all files in the source directory
Get-ChildItem -Path $sourceDir -File -Recurse | ForEach-Object {
    # Get the relative path
    $relativePath = $_.FullName.Substring($sourceDir.Length + 1)
    
    # Convert to forward slashes for R2
    $r2Path = $relativePath.Replace("\", "/")
    
    # Upload the file using wrangler
    Write-Host "Uploading: $($_.FullName) to $bucketName/$r2Path"
    wrangler r2 object put "$bucketName/$r2Path" "--file=$($_.FullName)"
}

Write-Host "Upload complete!" -ForegroundColor Green