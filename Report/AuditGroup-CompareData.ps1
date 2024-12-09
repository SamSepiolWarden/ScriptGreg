# Add verbose logging
$VerbosePreference = "Continue"

# Check if ImportExcel module is installed, if not install it
Write-Verbose "Checking for ImportExcel module..."
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Verbose "ImportExcel module not found. Installing..."
    Install-Module ImportExcel -Force -AllowClobber -Verbose
}
else {
    Write-Verbose "ImportExcel module found."
}

function Compare-ExcelFiles {
    param (
        [Parameter(Mandatory=$true)]
        [string]$File1Path,
        
        [Parameter(Mandatory=$true)]
        [string]$File2Path,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory=$false)]
        [string[]]$PropertiesToCompare = @('*')
    )

    try {
        # Verify input files exist
        Write-Verbose "Checking if input files exist..."
        if (-not (Test-Path $File1Path)) {
            throw "First file not found: $File1Path"
        }
        if (-not (Test-Path $File2Path)) {
            throw "Second file not found: $File2Path"
        }

        Write-Host "Starting comparison process..."
        Write-Host "First file: $File1Path"
        Write-Host "Second file: $File2Path"
        Write-Host "Output will be saved to: $OutputPath"

        # Import files based on extension
        Write-Verbose "Reading first file: $File1Path"
        if ($File1Path.EndsWith('.csv')) {
            $file1Data = Import-Csv -Path $File1Path
            Write-Host "First file loaded: $($file1Data.Count) rows"
        } else {
            $file1Data = Import-Excel -Path $File1Path
            Write-Host "First file loaded: $($file1Data.Count) rows"
        }

        Write-Verbose "Reading second file: $File2Path"
        if ($File2Path.EndsWith('.csv')) {
            $file2Data = Import-Csv -Path $File2Path
            Write-Host "Second file loaded: $($file2Data.Count) rows"
        } else {
            $file2Data = Import-Excel -Path $File2Path
            Write-Host "Second file loaded: $($file2Data.Count) rows"
        }

        # Create results collections
        $addedItems = [System.Collections.ArrayList]::new()
        $removedItems = [System.Collections.ArrayList]::new()
        $modifiedItems = [System.Collections.ArrayList]::new()

        # Create hashtables for faster lookup
        $file1Hash = @{}
        $file2Hash = @{}

        # Use UPN as the identifier
        $identifierColumn = 'UPN'

        # Build hashtables
        $file1Data | ForEach-Object { $file1Hash[$_.$identifierColumn] = $_ }
        $file2Data | ForEach-Object { $file2Hash[$_.$identifierColumn] = $_ }

        Write-Host "Comparing files..."
        
        # Compare files
        foreach ($upn in $file1Hash.Keys) {
            if ($file2Hash.ContainsKey($upn)) {
                $item1 = $file1Hash[$upn]
                $item2 = $file2Hash[$upn]
                
                $differences = @()
                foreach ($prop in $PropertiesToCompare) {
                    if ($item1.$prop -ne $item2.$prop) {
                        $differences += "$prop changed from '$($item1.$prop)' to '$($item2.$prop)'"
                    }
                }
                
                if ($differences.Count -gt 0) {
                    $null = $modifiedItems.Add([PSCustomObject]@{
                        'UPN' = $upn
                        'Change_Type' = 'Modified'
                        'Changes' = $differences -join '; '
                        'Original_Values' = ($item1 | ConvertTo-Json)
                        'New_Values' = ($item2 | ConvertTo-Json)
                    })
                }
            }
            else {
                $null = $removedItems.Add([PSCustomObject]@{
                    'UPN' = $upn
                    'Change_Type' = 'Removed'
                    'Original_Values' = ($file1Hash[$upn] | ConvertTo-Json)
                })
            }
        }

        foreach ($upn in $file2Hash.Keys) {
            if (-not $file1Hash.ContainsKey($upn)) {
                $null = $addedItems.Add([PSCustomObject]@{
                    'UPN' = $upn
                    'Change_Type' = 'Added'
                    'New_Values' = ($file2Hash[$upn] | ConvertTo-Json)
                })
            }
        }

        Write-Host "Creating Excel output file..."
        
        # Ensure output path has .xlsx extension
        if (-not $OutputPath.ToLower().EndsWith('.xlsx')) {
            $OutputPath = $OutputPath.Replace('.csv', '.xlsx')
        }

        # Create initial Excel file with summary
        $summaryData = @(
            [PSCustomObject]@{
                'Category' = 'Added Users'
                'Count' = $addedItems.Count
                'Details' = if($addedItems.Count -gt 0) { ($addedItems.UPN -join ', ') } else { 'No changes' }
            },
            [PSCustomObject]@{
                'Category' = 'Removed Users'
                'Count' = $removedItems.Count
                'Details' = if($removedItems.Count -gt 0) { ($removedItems.UPN -join ', ') } else { 'No changes' }
            },
            [PSCustomObject]@{
                'Category' = 'Modified Users'
                'Count' = $modifiedItems.Count
                'Details' = if($modifiedItems.Count -gt 0) { ($modifiedItems.UPN -join ', ') } else { 'No changes' }
            }
        )

        $summaryData | Export-Excel -Path $OutputPath -WorksheetName 'Summary' -AutoSize -AutoFilter

        # Only create sheets for categories that have changes
        if ($addedItems.Count -gt 0) {
            $addedItems | Export-Excel -Path $OutputPath -WorksheetName 'Added' -AutoSize -AutoFilter -Append
        }
        if ($removedItems.Count -gt 0) {
            $removedItems | Export-Excel -Path $OutputPath -WorksheetName 'Removed' -AutoSize -AutoFilter -Append
        }
        if ($modifiedItems.Count -gt 0) {
            $modifiedItems | Export-Excel -Path $OutputPath -WorksheetName 'Modified' -AutoSize -AutoFilter -Append
        }

        Write-Host "Comparison complete!"
        Write-Host "Added users: $($addedItems.Count)"
        Write-Host "Removed users: $($removedItems.Count)"
        Write-Host "Modified users: $($modifiedItems.Count)"
        Write-Host "Results saved to: $OutputPath"

        # If no changes were found at all, add a note about it
        if (($addedItems.Count + $removedItems.Count + $modifiedItems.Count) -eq 0) {
            Write-Host "No differences found between the files!"
            [PSCustomObject]@{
                'Result' = 'No differences found between the files'
                'Timestamp' = Get-Date
            } | Export-Excel -Path $OutputPath -WorksheetName 'No Changes' -AutoSize -Append
        }
    }
    catch {
        Write-Error "An error occurred: $_"
        Write-Error $_.ScriptStackTrace
    }
}

# Execute the comparison
Compare-ExcelFiles `
    -File1Path "C:\Users\GregorySemedo\Desktop\Script\Report\24-07-03 Review only-Marketing.csv" `
    -File2Path "C:\Users\GregorySemedo\Desktop\Script\Report\Only-Marketing.csv" `
    -OutputPath "C:\Users\GregorySemedo\Desktop\Script\Report\Compare.xlsx" `
    -PropertiesToCompare @('UPN', 'Group', 'Apps', 'Roles')