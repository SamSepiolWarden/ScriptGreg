$ExitCode = $LASTEXITCODE



if (Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue) {
    # Activer le compte 'Administrator' s'il existe
    Enable-LocalUser -Name "Administrator" 
    
    Write-Host "Le compte 'Administrator' a été activé."
    $ExitCode = 0
} else {
    # Sinon, vérifier si le compte 'Administrateur' existe
    if (Get-LocalUser -Name "Administrateur" -ErrorAction SilentlyContinue) {
        # Activer le compte 'Administrateur' s'il existe
        Enable-LocalUser -Name "Administrateur"
        
        Write-Host "Le compte 'Administrateur' a été activé."
        $ExitCode = 0
    }
}
Write-Host "Exit code: $ExitCode."
exit $ExitCode
