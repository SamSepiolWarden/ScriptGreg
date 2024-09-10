# Définir l'URL de téléchargement du programme d'installation de Visual Studio
$vsInstallerUrl = "https://aka.ms/vs/16/release/vs_enterprise.exe"

# Définir le chemin d'enregistrement du fichier d'installation de Visual Studio
$vsInstallerPath = "C:\Temp\vs_installer.exe"

# Télécharger le fichier d'installation de Visual Studio depuis l'URL
Invoke-WebRequest -Uri $vsInstallerUrl -OutFile $vsInstallerPath

# Lancer l'installation de Visual Studio en mode silencieux
& $vsInstallerPath --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\Enterprise" --add Microsoft.VisualStudio.Workload.NetCoreTools --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.Office --add Microsoft.VisualStudio.Workload.Universal --add Microsoft.VisualStudio.Workload.VisualStudioExtension --add Component.GitHub.VisualStudio --includeRecommended

# Vérifier que l'installation a réussi
if ($LASTEXITCODE -eq 0) {
    Write-Host "Visual Studio a été installé avec succès."
} else {
    Write-Host "L'installation de Visual Studio a échoué avec le code de sortie $LASTEXITCODE."
}
