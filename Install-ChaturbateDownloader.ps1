# Hinweis zur erforderlichen Streamlink-Version
Write-Host "Hinweis: Streamlink Version 1.7.0 oder höher ist erforderlich."

# Überprüfe, ob Streamlink installiert ist und die Version den Anforderungen entspricht
$streamlinkPath = "C:\Program Files (x86)\Streamlink\bin\streamlink.exe"
if (-Not (Test-Path -Path $streamlinkPath)) {
    Write-Host "Streamlink wurde nicht gefunden. Bitte installiere Streamlink Version 1.7.0 oder höher."
    exit 1
}

# Überprüfe die installierte Streamlink-Version
$streamlinkVersion = & "$streamlinkPath" --version
if ($streamlinkVersion -lt "1.7.0") {
    Write-Host "Installierte Streamlink-Version: $streamlinkVersion. Bitte aktualisiere auf Version 1.7.0 oder höher."
    exit 1
}

# Setze die Execution Policy auf RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Definiere die Zielverzeichnisse
$moduleTargetDir = "C:\Program Files\WindowsPowerShell\Modules\ChaturbateDownloader"
$pluginTargetDir = "C:\Program Files (x86)\Streamlink\pkgs\streamlink\plugins"

# Hole das aktuelle Verzeichnis
$sourceDir = (Get-Location).Path

# Stelle sicher, dass die Zielverzeichnisse existieren
if (-not (Test-Path -Path $moduleTargetDir)) {
    New-Item -ItemType Directory -Path $moduleTargetDir -Force
}

if (-not (Test-Path -Path $pluginTargetDir)) {
    New-Item -ItemType Directory -Path $pluginTargetDir -Force
}

# Kopiere die Moduldateien
Copy-Item -Path "$sourceDir\ChaturbateDownloader.psm1" -Destination $moduleTargetDir -Force
Copy-Item -Path "$sourceDir\ChaturbateDownloader.psd1" -Destination $moduleTargetDir -Force

# Kopiere die Plugin-Datei
Copy-Item -Path "$sourceDir\source\chaturbate.py" -Destination $pluginTargetDir -Force

# Importiere das Modul
Import-Module "$moduleTargetDir\ChaturbateDownloader.psm1" -Verbose

Write-Host "Installation abgeschlossen. Das Modul ChaturbateDownloader und das Plugin chaturbate.py wurden erfolgreich installiert und importiert."