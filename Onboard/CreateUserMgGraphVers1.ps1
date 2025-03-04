Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "UserAuthenticationMethod.ReadWrite.All"

function Get-UserExtensionAttributes {
    param (
        [string]$UserId
    )
    try {
        # Search for the user by ID and fetch onPremisesExtensionAttributes
        $User = Get-MgUser -UserId $UserId -Select "onPremisesExtensionAttributes"
        if ($null -ne $User) {
            Write-Host "Current extension attributes for user $($User.DisplayName):" -ForegroundColor Cyan
            # Loop through extension attributes 1 to 15
            for ($i = 1; $i -le 15; $i++) {
                $attributeName = "extensionAttribute$i"
                $attributeValue = $User.onPremisesExtensionAttributes.$attributeName
                Write-Host "${attributeName}: ${attributeValue}"
            }
        } else {
            Write-Host "No extension attributes found."
        }
    } catch {
        Write-Host "Failed to retrieve extension attributes for user ID $UserId" -ForegroundColor Red
    }
}

# Prompt for the user's email address to create
$email = Read-Host -Prompt "Enter the email address of the user to create"
$FirstName = Read-Host -Prompt "Enter the first name of the user to create"
$LastName = Read-Host -Prompt "Enter the last name of the user to create"
$Password = Read-Host -Prompt "Enter the password of the user to create" -AsSecureString

$PasswordProfile = @{
    "Password" = $Password
    "ForceChangePasswordNextSignIn" = $true
}

$UsageLocation = Read-Host -Prompt "Enter the usage location of the user to create"
$OfficeLocation = Read-Host -Prompt "Enter the office location of the user to create (ex: Paris, Lyon, Mumbai, Boston)"
# List the departments available
$Departments = Get-MgBetaUser -All | Select-Object -ExpandProperty Department | Sort-Object -Unique
foreach ($Department in $Departments) {
    Write-Host $Department
}

$Department = Read-Host -Prompt "Enter the Department of the user to add"
# Create the user
New-MgUser -UserPrincipalName $email -DisplayName "$FirstName $LastName" -PasswordProfile $PasswordProfile -AccountEnabled:$false -MailNickname "$FirstName.$LastName" -Department $Department -GivenName $FirstName -Surname $LastName

if ($?) {
    $CheckUser = Get-MgUser -Filter "UserPrincipalName eq '$email'"
    if ($null -ne $CheckUser) {
        Write-Host "User created successfully" -ForegroundColor Green
        Update-MgUser -UserID $CheckUser.Id -UsageLocation $UsageLocation -OfficeLocation $OfficeLocation
        if ($?) {
            Write-Host "Usage location set successfully" -ForegroundColor Green
        } else {
            Write-Host "Failed to set usage location" -ForegroundColor Red
        }
    } else {
        Write-Host "Failed to create user" -ForegroundColor Red
    }
}

# Get all licenses available
$AllLicenses = Get-MgSubscribedSku
$LicenseOptions = @()
$LicenseMap = @{}

$AllLicenses | ForEach-Object {
    $LicenseOptions += [System.Management.Automation.Host.ChoiceDescription]::new("&$($_.SkuPartNumber)", "Get assigned $($_.SkuPartNumber)")
    $LicenseMap[$_.SkuPartNumber] = $_.SkuId
}

# Check if the user was created successfully
do {
    if ($?) {
        $Result = $host.UI.PromptForChoice('Task Menu', 'Select a License', $LicenseOptions, 0)
        $SelectedLicense = $LicenseOptions[$Result].Label.TrimStart('&')
        $LicenseId = $LicenseMap[$SelectedLicense]

        $UserFilter = Get-MgUser -Filter "UserPrincipalName eq '$email'"
        # Check if there are licenses available
        Start-Sleep -Seconds 5
        Set-MgUserLicense -UserId $UserFilter.Id -AddLicenses @{ SkuId = "$LicenseId" } -RemoveLicenses @()
        if ($?) {
            Write-Host "License $SelectedLicense assigned to $email" -ForegroundColor Green
        } else {
            Write-Host "No more licenses available or error occurred" -ForegroundColor Red
        }
    } else {
        Write-Host "An error occurred." -ForegroundColor Red
    }

    $Ask = Read-Host -Prompt "Do you want to add another license? (Y/N)"
} while ($Ask -eq 'Y')

Start-Sleep -Seconds 5

# Add the manager to the user
$Manager = Read-Host -Prompt "Enter the Display name of the manager to add"
$ManagerId = (Get-MgUser -Filter "DisplayName eq '$Manager'").Id

$Params = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
} | ConvertTo-Json

Set-MgUserManagerByRef -UserId $UserFilter.Id -BodyParameter $Params
if ($?) {
    Write-Host "Manager $Manager assigned to $email" -ForegroundColor Green
} else {
    Write-Host "Manager $Manager not assigned to $email" -ForegroundColor Red
}

# Ask for modify extension attribute of the user
$AskAttribute = Read-Host -Prompt "Do you want to modify the extension attribute of the user? (Y/N)"
if ($AskAttribute -eq 'Y') {
    # Initialize the loop control variable
    $continue = $true

    # Start the loop
    while ($continue) {
        # Search for the user with the specified UserPrincipalName
        try {
            $SearchUser = Get-MgUser -Filter "userPrincipalName eq '$email'"
        } catch {
            Write-Host "An error occurred while searching for the user." -ForegroundColor Red
            continue
        }

        # Check if the user is found
        if ($null -eq $SearchUser) {
            Write-Host "User not found."
        } else {
            # Fetch and display current extension attributes
            Get-UserExtensionAttributes -UserId $SearchUser.Id
        }

        # Ask if the user wants to add or modify an extension attribute
        $ModifyExtension = Read-Host -Prompt "Do you want to add or modify an extension attribute? (Y/N)"
        if ($ModifyExtension -eq "Y") {
            $ExtensionNum = Read-Host -Prompt "Enter the extension number (1-15) you wish to add or modify"
            $ExtensionValue = Read-Host -Prompt "Enter the new value for the extension attribute"

            # Update or add the extension attribute
            try {
                $updateParams = @{
                    OnPremisesExtensionAttributes = @{("extensionAttribute" + $ExtensionNum) = $ExtensionValue}
                }
                Update-MgUser -UserId $SearchUser.Id -BodyParameter $updateParams
                if ($?) {
                    Write-Host "Extension attribute updated successfully." -ForegroundColor Green
                }
                # Fetch and display current extension attributes
                Get-UserExtensionAttributes -UserId $SearchUser.Id
            } catch {
                Write-Host "Failed to update extension attribute."
                Write-Host $_.Exception.Message
            }
        } else {
            Write-Host "No changes made."
        }

        # Ask if the user wants to repeat the process
        $repeat = Read-Host -Prompt "Do you want to modify another user? (Y/N)"
        if ($repeat -ne "Y") {
            $continue = $false
        }
    }
} else {
    Write-Host "No Extension Attribute change made."
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph