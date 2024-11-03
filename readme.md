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


## Dauerhaft Importieren

Ja, Sie können das Modul dauerhaft importieren, indem Sie es in Ihr PowerShell-Profilskript einfügen. Das PowerShell-Profilskript wird jedes Mal ausgeführt, wenn Sie eine neue PowerShell-Sitzung starten.

### Schritt 1: Öffnen Sie Ihr PowerShell-Profilskript

Öffnen Sie Ihr PowerShell-Profilskript in einem Texteditor. Sie können dies direkt in PowerShell tun:

```powershell
notepad $PROFILE
```

Falls das Profilskript noch nicht existiert, wird es durch diesen Befehl erstellt.

### Schritt 2: Fügen Sie den Import-Befehl hinzu

Fügen Sie den folgenden Befehl am Ende Ihres Profilskripts hinzu, um das Modul `ChaturbateDownloader` bei jedem Start von PowerShell zu importieren:

```powershell
Import-Module "C:\Program Files\WindowsPowerShell\Modules\ChaturbateDownloader\ChaturbateDownloader.psm1"
```

### Schritt 3: Speichern und schließen Sie das Profilskript

Speichern Sie die Änderungen und schließen Sie den Texteditor.

### Schritt 4: Starten Sie PowerShell neu

Starten Sie PowerShell neu, um sicherzustellen, dass das Modul automatisch importiert wird.

### Beispiel für das Profilskript

Hier ist ein Beispiel, wie Ihr Profilskript aussehen könnte:

```powershell
# PowerShell-Profilskript

# Andere benutzerdefinierte Einstellungen und Funktionen

# Importiere das ChaturbateDownloader-Modul
Import-Module "C:\Program Files\WindowsPowerShell\Modules\ChaturbateDownloader\ChaturbateDownloader.psm1"
```

Durch diese Schritte wird das Modul `ChaturbateDownloader` bei jedem Start von PowerShell automatisch importiert.

## Verwendung

Nach der Installation können Sie die Funktion `Download-ChaturbateStream` wie folgt verwenden:

```powershell
Download-ChaturbateStream -Username "Benutzername"


