# Function to get BIOS information
function Get-BiosInfo {
    $bios = Get-CimInstance -ClassName Win32_BIOS
    return [PSCustomObject]@{
        BIOSVersion = $bios.SMBIOSBIOSVersion
        SerialNumber = $bios.SerialNumber
    }
}

# Function to get computer system information
function Get-ComputerSystemInfo {
    $system = Get-CimInstance -ClassName Win32_ComputerSystem
    return [PSCustomObject]@{
        Model = $system.Model
    }
}

# Main function to get and output the information
function Get-DeviceBiosInfo {
    $biosInfo = Get-BiosInfo
    $systemInfo = Get-ComputerSystemInfo

    $deviceInfo = [PSCustomObject]@{
        Model = $systemInfo.Model
        BIOSVersion = $biosInfo.BIOSVersion
        SerialNumber = $biosInfo.SerialNumber
    }

    return $deviceInfo
}

# Execute the main function and output the results
$deviceInfo = Get-DeviceBiosInfo

# Output the information for Intune in a single line
Write-Output "Model: $($deviceInfo.Model), BIOSVersion: $($deviceInfo.BIOSVersion), SerialNumber: $($deviceInfo.SerialNumber)"
