<#
    Script PowerShell pour désactiver le partage des sites personnels OneDrive dans SharePoint Online.
    Assurez-vous d'avoir les permissions nécessaires pour exécuter ce script.
    Assurez-vous d'avoir installé le module SharePoint Online Management Shell.
    --> Install-Module -Name Microsoft.Online.SharePoint.PowerShell

#>
# Connexion à SharePoint Online
Connect-SPOService -Url "https://<votre-tenant>-admin.sharepoint.com"

# Récupérer tous les sites personnels (OneDrive)
$sites = Get-SPOSite -IncludePersonalSite $true -Limit All | Where-Object { $_.Url -like "*-my.sharepoint.com/personal/*" }

foreach ($site in $sites) {
    Write-Host "Traitement du site : $($site.Url)"

    # Vérifier l'état actuel du partage
    if ($site.SharingCapability -ne "Disabled") {
        # Désactiver le partage
        Set-SPOSite -Identity $site.Url -SharingCapability Disabled
        Write-Host "Partage désactivé pour : $($site.Url)"
    }
    else {
        Write-Host "Déjà désactivé : $($site.Url)"
    }
}
