
Connect-MgGraph


$PSScripts = Get-MgBetaDeviceManagementScript

if ($PSScripts) {

    write-host "-------------------------------------------------------------------"
    Write-Host

    $PSScripts | ForEach-Object {

        $ScriptId = $_.id
        $DisplayName = $_.displayName

        Write-Host "PowerShell Script: $DisplayName..." -ForegroundColor Yellow

        $_

        write-host "Device Management Scripts - Assignments" -f Cyan

        $Assignments = Get-MgBetaDeviceManagementScriptAssignment -DeviceManagementScriptId $_.Id

        if ($Assignments) {

            foreach ($Group in $Assignments) {
                $parts = $group.Id -split ":"
                $gid = $parts[1]
            (Get-MgGroup -GroupId $gid).displayName

            }

            Write-Host

        }

        else {

            Write-Host "No assignments set for this policy..." -ForegroundColor Red
            Write-Host

        }

        $Script = Get-MgBetaDeviceManagementScript -DeviceManagementScriptId $ScriptId

        $ScriptContent = $Script.scriptContent

        Write-Host "Script Content:" -ForegroundColor Cyan

        [System.Text.Encoding]::UTF8.GetString($script.ScriptContent)
        Write-Host
        write-host "-------------------------------------------------------------------"
        Write-Host

    }

}

else {

    Write-Host
    Write-Host "No PowerShell scripts have been added to the service..." -ForegroundColor Red
    Write-Host

}