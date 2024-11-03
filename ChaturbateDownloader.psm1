function Get-ChaturbateStream {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Username
    )

    # Definiere die URL des Chaturbate-Streams
    $streamUrl = "https://chaturbate.com/$Username/"

    # Erstelle einen Zeitstempel
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    # Definiere den Speicherort und Dateinamen
    $outputDir = "C:\temp"
    $outputFile = "$outputDir\$Username`_$timestamp.mp4"

    # Stelle sicher, dass der Speicherort existiert
    if (-not (Test-Path -Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir
    }

    # Pfad zu Streamlink.exe
    $streamlinkPath = "C:\Program Files (x86)\Streamlink\bin\streamlink.exe"
    $quality = "best"  # Qualität des Streams (z.B. "best", "720p", etc.)

    # Baue den Streamlink-Befehl, um den Stream-Link zu extrahieren
    $arguments = "$streamUrl $quality --stream-url"

    # Führe den Befehl aus und speichere den Stream-Link
    $streamLink = & $streamlinkPath $arguments

    # Extrahiere nur die URL aus dem Output
    $streamLink = $streamLink | Select-String -Pattern "http.*" | ForEach-Object { $_.Matches[0].Value }

    # Gib den m3u8-Link in der Konsole aus
    Write-Host "Stream-URL: $streamLink"

    # Baue den Streamlink-Befehl zum Herunterladen des Streams
    $downloadArguments = "$streamUrl $quality -o `"$outputFile`""

    # Führe den Befehl aus
    Start-Process -FilePath $streamlinkPath -ArgumentList $downloadArguments -NoNewWindow -Wait

    Write-Host "Stream-Download abgeschlossen"
}