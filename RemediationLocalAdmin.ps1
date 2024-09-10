$ExitCode = $LASTEXITCODE

# Convert the plain text password to a secure string
$securePassword = ConvertTo-SecureString "TsEv*kL&M%e2Wu" -AsPlainText -Force

if (Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue) {
    # Activer le compte 'Administrator' s'il existe
    Enable-LocalUser -Name "Administrator" 
    Set-LocalUser -Name "Administrator" -Password $securePassword
    Write-Host "Le compte 'Administrator' a été activé."
    $ExitCode = 0
} else {
    # Sinon, vérifier si le compte 'Administrateur' existe
    if (Get-LocalUser -Name "Administrateur" -ErrorAction SilentlyContinue) {
        # Activer le compte 'Administrateur' s'il existe
        Enable-LocalUser -Name "Administrateur"
        Set-LocalUser -Name "Administrateur" -Password $securePassword
        Write-Host "Le compte 'Administrateur' a été activé."
        $ExitCode = 0
    }
}
Write-Host "Exit code: $ExitCode."
exit $ExitCode