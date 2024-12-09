# Check if ImportExcel module is installed
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "Installing ImportExcel module..."
    Install-Module ImportExcel -Force -AllowClobber -Verbose
}

function Compare-LineCounts {
    param (
        [Parameter(Mandatory=$true)]
        [string]$File1Path,

        [Parameter(Mandatory=$true)]
        [string]$File2Path,

        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )

    try {
        # Import files
        Write-Host "Importing File1: $File1Path"
        $file1Data = Import-Csv -Path $File1Path
        Write-Host "Importing File2: $File2Path"
        $file2Data = Import-Csv -Path $File2Path

        # Count lines grouped by UPN in each file
        $file1Counts = $file1Data | Group-Object -Property UPN | ForEach-Object {
            [PSCustomObject]@{
                UPN = $_.Name
                Lines_in_File1 = $_.Count
                Lines_in_File2 = 0
            }
        }

        $file2Counts = $file2Data | Group-Object -Property UPN | ForEach-Object {
            [PSCustomObject]@{
                UPN = $_.Name
                Lines_in_File1 = 0
                Lines_in_File2 = $_.Count
            }
        }

        # Combine results from both files
        $combinedCounts = @($file1Counts + $file2Counts) | Group-Object -Property UPN | ForEach-Object {
            $group = $_.Group
            $file1Count = ($group | Where-Object { $_.Lines_in_File1 -ne 0 }).Lines_in_File1 | Measure-Object -Sum | Select-Object -ExpandProperty Sum
            $file2Count = ($group | Where-Object { $_.Lines_in_File2 -ne 0 }).Lines_in_File2 | Measure-Object -Sum | Select-Object -ExpandProperty Sum

            [PSCustomObject]@{
                UPN = $_.Name
                Lines_in_File1 = $file1Count
                Lines_in_File2 = $file2Count
                Difference = $file1Count - $file2Count
            }
        }

        # Export results to Excel
        Write-Host "Exporting results to Excel at: $OutputPath"
        $combinedCounts | Export-Excel -Path $OutputPath -WorksheetName 'Line Count Differences' -AutoSize -AutoFilter

        Write-Host "Comparison complete! Results saved to: $OutputPath"
    }
    catch {
        Write-Error "An error occurred: $_"
        Write-Error $_.ScriptStackTrace
    }
}

# Execute the comparison
Compare-LineCounts `
    -File1Path "C:\Users\YourUsername\Path\To\24-07-03 Review only-Marketing.csv" `
    -File2Path "C:\Users\YourUsername\Path\To\Only-Marketing.csv" `
    -OutputPath "C:\Users\YourUsername\Path\To\LineCountComparison.xlsx"
