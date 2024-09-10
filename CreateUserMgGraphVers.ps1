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

# Prompt for the user's email adress to create
$email = Read-Host -Prompt "Enter the email address of the user to create"
$FirstName = Read-Host -Prompt "Enter the first name of the user to create"
$LastName = Read-Host -Prompt "Enter the last name of the user to create"
$Password = Read-Host -Prompt "Enter the password of the user to create" -AsSecureString

$PasswordProfile = @{
    "Password" = $Password
    "ForceChangePasswordNextSignIn" = $true
}

$UsageLocation = Read-Host -Prompt "Enter the usage location of the user to create"
$OfficeLocation = Read-Host -Prompt "Enter the office location of the user to create(ex: Paris, Lyon, Mumbai, boston)"
# Lister les departement disponible
$Departements = Get-MgBetaUser -All | Select-Object -ExpandProperty Department | Sort-Object -Unique
foreach ($Departement in $Departements)
{
    Write-Host $Departement
}

$Department = Read-Host -Prompt "Enter the Department of the user to add"
# Create the user
New-MgUser -UserPrincipalName $email -DisplayName "$FirstName $LastName" -PasswordProfile $PasswordProfile -AccountEnabled:$false -MailNickname "$FirstName.$LastName" -Department $Department -GivenName $FirstName -Surname $LastName

if ($?) {

$CheckUser = Get-MgUser -Filter "UserPrincipalName eq '$email'"
if($null -ne $CheckUser) {
Write-Host "User created successfully" -ForegroundColor Green
Update-MgUser -UserID $CheckUser.Id -UsageLocation $UsageLocation -OfficeLocation $OfficeLocation
if ($?) {
Write-Host "Usage location set successfully" -ForegroundColor Green
}
else {
Write-Host "Failed to set usage location" -ForegroundColor Red
}
}
else {
Write-Host "Failed to create user" -ForegroundColor Red
}
}

#Get all licences available
$AllLicences = Get-MgSubscribedSku
$AllLicences |  ForEach-Object {
    $prepaidUnits = $_.PrepaidUnits
    $consumedUnits = $_.ConsumedUnits

    Write-Host "SKU ID: $($_.SkuId)"
    Write-Host "SKU Part Number: $($_.SkuPartNumber)"
    
    Write-Host "Prepaid Units:"
    Write-Host "    Enabled: $($prepaidUnits.Enabled)"
    Write-Host "    Suspended: $($prepaidUnits.Suspended)"
    Write-Host "    Warning: $($prepaidUnits.Warning)"
    
    Write-Host "Consumed Units: $consumedUnits"
    Write-Host "-----------------------"
}
# Check if the user was created successfully
do {
    if ($?)
    {
        $Licence = [System.Management.Automation.Host.ChoiceDescription]::new('&Office')
        $OfficeE3 = New-Object System.Management.Automation.Host.ChoiceDescription '&OfficeE3', 'Get assigned OfficeE3'
        $TVM = New-Object System.Management.Automation.Host.ChoiceDescription '&TVM', 'Get assigned TVM'
        $PowerBiPro = New-Object System.Management.Automation.Host.ChoiceDescription '&PowerBiPro', 'Get assigned PowerBiPro'
        $F3 = New-Object System.Management.Automation.Host.ChoiceDescription '&F3', 'Get assigned F3'
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($OfficeE3, $TVM, $PowerBiPro, $F3)
        $Result = $host.UI.PromptForChoice('Task Menu', 'Select a Licence', $options, 0)

        switch ($Result) {
            0 { $Licence = Read-Host -Prompt "Enter the licence ID of office E3"}
            1 { $Licence = Read-Host -Prompt "Enter the licence ID of TVM"}
            2 { $Licence = Read-Host -Prompt "Enter the licence ID of PowerBiPro"}
            3 { $Licence = Read-Host -Prompt "Enter the licence ID of F3"}
        }

        $UserFilter = Get-MgUser -Filter "UserPrincipalName eq '$email'" 
        # Check if there are licenses available
Start-Sleep -Seconds 5
        Set-MgUserLicense -UserId $UserFilter.Id -AddLicenses @{ SkuId = "$Licence" } -RemoveLicenses @()
        if ($?) {
            Write-Host "Licence Office, Tvm... assigned to $email" -ForegroundColor Green
        } else {
            Write-Host "No more licences available or error occurred" -ForegroundColor Red
        }
    }
    else
    {
        Write-Host "An error occurred." -ForegroundColor Red
    }

    $Ask = Read-Host -Prompt "Do you want to add another licence? (Y/N)"
} while ($Ask -eq 'Y')
Start-Sleep -Seconds 5
# Add the manager to the user
$Manager = Read-Host -Prompt "Enter the Display name of the manager to add"
$ManagerId = (Get-Mguser -Filter "DisplayName eq '$Manager'").id

$Params = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
} | ConvertTo-Json


Set-MgUserManagerByRef -UserId $UserFilter.Id  -BodyParameter $Params
if ($?) {
    Write-Host "Manager $Manager assigned to $Username" -ForegroundColor Green
}
else {
    Write-Host "Manager $Manager not assigned to $Username" -ForegroundColor Red
}

  

    
# add the user to a group
if ($Department -notcontains "Product-Rnd") {


$GroupId = Get-MgGroup -Filter "DisplayName eq 'Enrollment - Enrollment as User (Other Department)'" | Select-Object -ExpandProperty Id
 New-MgGroupMember -GroupId $GroupId -DirectoryObjectID $UserFilter.Id
 if($?) {
     Write-Host "User $email added to group SOCIABBLE - Enrollment - Enrollment as User (Other Department)" -ForegroundColor Green
 }
 else {
     Write-Host "User $email not added to group SOCIABBLE - Apps&Enrollment - Enrollment as User (Other Department)" -ForegroundColor Red
 }
 $GroupId2 = Get-MgGroup -Filter "DisplayName eq 'Apps - Company Portal - (Other Department)'" | Select-Object -ExpandProperty Id
 New-MgGroupMember -GroupId $GroupId2 -DirectoryObjectID $UserFilter.Id
    if($?) {
        Write-Host "User $email added to group SOCIABBLE - Apps - Company Portal - (Other Department)" -ForegroundColor Green
    }
    else {
        Write-Host "User $email not added to group SOCIABBLE - Apps - Company Portal - (Other Department)" -ForegroundColor Red
    }
}
if ($Department -contains "Product-Rnd") {
    $GroupId1 = Get-MgGroup -Filter "DisplayName eq 'Enrollment - Enrollment as User (R&D)'" | Select-Object -ExpandProperty Id
 New-MgGroupMember -GroupId $GroupId1 -DirectoryObjectID $UserFilter.Id
    if($?) {
        Write-Host "User $email added to group SOCIABBLE - Enrollment - Enrollment as User (R&D)" -ForegroundColor Green
    }
    else {
        Write-Host "User $email not added to group SOCIABBLE - Apps&Enrollment - Enrollment as User (R&D)" -ForegroundColor Red
    }
    $GroupId3 = Get-MgGroup -Filter "DisplayName eq 'Apps - Company Portal - RnD'" | Select-Object -ExpandProperty Id
 New-MgGroupMember -GroupId $GroupId3 -DirectoryObjectID $UserFilter.Id
    if($?) {
        Write-Host "User $email added to group SOCIABBLE - Apps - Company Portal - RnD" -ForegroundColor Green
    }
    else {
        Write-Host "User $email not added to group SOCIABBLE - Apps - Company Portal - RnD" -ForegroundColor Red
    }
}
# Ask for modify extension attribute of the user
$AskAttribute = Read-Host -Prompt "Do you want to modify the extension attribute of the user? (Y/N)"
if ($AskAttribute -eq 'Y'){
# Initialize the loop control variable
$continue = $true

# Start the loop
while ($continue) {

    # Search for the user with the specified UserPrincipalName
    try {
        $SearchUser = Get-MgUser -Filter "userPrincipalName eq '$CheckUser'"
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
}
else {
    Write-Host "No Extension Attribute change made."
}
#Disconnect-MgGraph
Disconnect-MgGraph