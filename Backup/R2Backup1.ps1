# --- Configuration ---
$sourceDir = "C:\Users\grego\Desktop\Perso\ScriptGreg"
$bucketName = "backup-drive"

# --- Validation de l'entrée ---
if (-not (Test-Path -Path $sourceDir -PathType Container)) {
    Write-Error "Le répertoire source n'existe pas ou n'est pas un répertoire : $sourceDir"
    exit 1
}

# --- Vérification de l'authentification Wrangler (méthode basique) ---
# Cette vérification n'est pas parfaite.  Elle vérifie juste si la commande
# wrangler est disponible.  Une vérification plus robuste impliquerait
# d'exécuter une commande comme 'wrangler whoami' et d'analyser la sortie.
if (-not (Get-Command wrangler -ErrorAction SilentlyContinue)) {
    Write-Error "wrangler n'est pas installé ou n'est pas dans votre PATH.  Installez-le avec 'npm install -g wrangler' et assurez-vous d'être connecté (npx wrangler login)."
    exit 1
}
try {
    $wranglerWhoAmI = npx wrangler whoami
    if ($wranglerWhoAmI -notmatch 'account_id')
    {
         Write-Error "wrangler n'est authentifié.  Connectez vous avec (npx wrangler login)."
         exit 1
    }
}
catch
{
    Write-Error "Erreur lors de la vérification de l'authentification wrangler : $($_.Exception.Message)"
    exit 1
}


# --- Traitement des fichiers ---

# Utilisation d'un try-catch global pour gérer les erreurs imprévues
try {
    # Start-Transcript -Path "C:\chemin\vers\votre\fichier\log.txt" -Append # Optionnel : Pour un log détaillé.  Décommentez si besoin.

    Get-ChildItem -Path $sourceDir -File -Recurse | ForEach-Object {
        # --- Calcul du chemin relatif (simplifié) ---
        $relativePath = $_.FullName.Substring($sourceDir.Length).TrimStart("\")

        # --- Conversion vers le format R2 (forward slashes et URL encoding) ---
        $r2Path = $relativePath.Replace("\", "/")
        $encodedR2Path = [System.Web.HttpUtility]::UrlEncode($r2Path)  # URL Encoding!

        # --- Upload du fichier avec gestion d'erreur DANS la boucle ---
        $fullBucketPath = "$bucketName/$encodedR2Path"
        Write-Host "Uploading: $($_.FullName) to $fullBucketPath"
        try {
            # Redirige stderr vers stdout (2>&1) pour capturer les erreurs de wrangler.
            $output = npx wrangler r2 object put $fullBucketPath --file "$($_.FullName)" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Erreur lors de l'upload de $($_.FullName): $output"
                # Ici, on pourrait choisir de continuer (continue) ou de s'arrêter (break).
            } else {
                Write-Host "Upload réussi: $fullBucketPath" -ForegroundColor Green
            }
        }
        catch {
            Write-Error "Erreur lors de l'upload de $($_.FullName): $($_.Exception.Message)"
            # Ici, on pourrait choisir de continuer (continue) ou de s'arrêter (break).
        }
    }
}
catch {
    Write-Error "Une erreur inattendue s'est produite: $($_.Exception.Message)"
    exit 1  # Quitte le script en cas d'erreur grave.
}
finally {
    # Stop-Transcript  # Si Start-Transcript a été utilisé.
    Write-Host "Script terminé."
}



# --- Optionnel : Uploads parallèles (avec prudence) ---
#  Cette section est commentée par défaut, car elle est plus avancée
#  et peut nécessiter des ajustements en fonction de votre environnement.
#  Elle montre comment utiliser Start-Job pour paralléliser les uploads.

#$maxParallelUploads = 5  # Limite le nombre d'uploads simultanés

#Get-ChildItem -Path $sourceDir -File -Recurse | ForEach-Object {
#    $relativePath = $_.FullName.Substring($sourceDir.Length).TrimStart("\")
#    $r2Path = $relativePath.Replace("\", "/")
#    $encodedR2Path = [System.Web.HttpUtility]::UrlEncode($r2Path)
#    $fullBucketPath = "$bucketName/$encodedR2Path"
#
#    Write-Host "Préparation de l'upload (parallèle): $($_.FullName)"
#    Start-Job -ScriptBlock {
#        param($filePath, $bucketPath)
#        try {
#            $output = npx wrangler r2 object put $bucketPath --file "$filePath" 2>&1
#             if ($LASTEXITCODE -ne 0) {
#                Write-Error "Erreur (job) lors de l'upload de $filePath: $output"
#            } else {
#                Write-Host "Upload réussi (job): $bucketPath"
#            }
#        }
#        catch {
#            Write-Error "Erreur (job) lors de l'upload de $filePath: $($_.Exception.Message)"
#        }
#    } -ArgumentList $_.FullName, $fullBucketPath
#
#    # Limite le nombre de jobs en cours d'exécution
#    while ((Get-Job -State Running).Count -ge $maxParallelUploads) {
#        Start-Sleep -Milliseconds 100
#    }
#}
#
## Attend que tous les jobs soient terminés.
#Get-Job | Wait-Job | Receive-Job
#Write-Host "Uploads parallèles terminés."