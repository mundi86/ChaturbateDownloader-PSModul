# ChaturbateDownloader

Ein PowerShell-Modul zum Herunterladen von Chaturbate-Streams.

## Projektübersicht

Dieses Projekt besteht aus mehreren Dateien:

- `chaturbate.py`: Ein Plugin für Streamlink, das den Stream von Chaturbate extrahiert.
- `ChaturbateDownloader.psd1`: Das Manifest für das PowerShell-Modul.
- `ChaturbateDownloader.psm1`: Das PowerShell-Modul, das die Funktion `Download-ChaturbateStream` enthält.
- `Install-ChaturbateDownloader.ps1`: Ein Installationsskript, das das Modul und das Plugin installiert.
- `streamlink-1.7.0.exe`: Die ausführbare Datei für Streamlink Version 1.7.0.

## Installation

Führen Sie die folgenden Schritte aus, um das Projekt zu installieren:

1. Stellen Sie sicher, dass Streamlink Version 1.7.0 oder höher installiert ist. Sie können die mitgelieferte `streamlink-1.7.0.exe` verwenden oder eine neuere Version von der [offiziellen Streamlink-Website](https://streamlink.github.io/install.html) herunterladen.

2. Führen Sie das Installationsskript `Install-ChaturbateDownloader.ps1` aus, um das Modul und das Plugin zu installieren. Öffnen Sie dazu eine PowerShell-Konsole mit Administratorrechten und führen Sie den folgenden Befehl aus:

    ```powershell
    .\Install-ChaturbateDownloader.ps1
    ```

    Das Skript überprüft, ob Streamlink installiert ist und die erforderliche Version hat. Es setzt die Execution Policy auf `RemoteSigned`, erstellt die erforderlichen Verzeichnisse und kopiert die Modul- und Plugin-Dateien an die entsprechenden Orte.

3. Nach erfolgreicher Installation können Sie das Modul importieren und die Funktion `Download-ChaturbateStream` verwenden, um Chaturbate-Streams herunterzuladen.

## Verwendung

Nach der Installation können Sie die Funktion `Download-ChaturbateStream` wie folgt verwenden:

```powershell
Download-ChaturbateStream -Username "Benutzername"