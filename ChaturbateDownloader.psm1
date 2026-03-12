#Requires -Version 5.1
<#
.SYNOPSIS
    Downloads Chaturbate streams with automatic reconnect and timestamped logging.

.DESCRIPTION
    Uses Streamlink to download a Chaturbate user's live stream.
    Automatically reconnects when a stream drops and logs all events
    to both the console (color-coded) and a log file.

.NOTES
    Author  : myCode
    Version : 2.0.0
    License : MIT
#>

function Write-StreamLog {
    <#
    .SYNOPSIS
        Writes a timestamped log entry to the console and optionally to a log file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO',

        [string]$LogFile
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry     = "[$timestamp] [$Level] $Message"

    switch ($Level) {
        'INFO'    { Write-Host   $entry -ForegroundColor Cyan   }
        'WARN'    { Write-Host   $entry -ForegroundColor Yellow }
        'ERROR'   { Write-Host   $entry -ForegroundColor Red    }
        'SUCCESS' { Write-Host   $entry -ForegroundColor Green  }
    }

    if ($LogFile) {
        try {
            Add-Content -Path $LogFile -Value $entry -Encoding UTF8
        }
        catch {
            Write-Host "[WARN] Could not write to log file: $_" -ForegroundColor Yellow
        }
    }
}


function Get-ChaturbateStream {
    <#
    .SYNOPSIS
        Downloads a Chaturbate live stream with auto-reconnect on stream drops.

    .DESCRIPTION
        Continuously monitors and records a Chaturbate stream using Streamlink.
        When the stream drops or the connection is interrupted, the function
        waits for RetryDelay seconds and then attempts to reconnect — up to
        MaxRetries times total.

        Each recording segment is saved with a unique timestamp so no data
        is overwritten between retries.

        All events are logged to the console (color-coded) and to a log file.

    .PARAMETER Username
        The Chaturbate username to record.

    .PARAMETER OutputDir
        Directory where recordings are saved.
        Defaults to "C:\Users\<you>\Videos\ChaturbateDownloader".

    .PARAMETER Quality
        Streamlink quality setting. Examples: "best", "worst", "720p", "480p".
        Defaults to "best".

    .PARAMETER MaxRetries
        Maximum number of reconnection attempts after a stream drop.
        Set to 0 for unlimited retries.
        Defaults to 50.

    .PARAMETER RetryDelay
        Seconds to wait between reconnection attempts.
        Defaults to 30.

    .PARAMETER StreamlinkPath
        Full path to the streamlink.exe binary.
        If not provided, the function searches common installation paths and PATH.

    .PARAMETER LogFile
        Path to the log file. Defaults to "<OutputDir>\<Username>_downloader.log".

    .EXAMPLE
        Get-ChaturbateStream -Username "someuser"

    .EXAMPLE
        Get-ChaturbateStream -Username "someuser" -Quality "720p" -MaxRetries 10 -RetryDelay 60

    .EXAMPLE
        Get-ChaturbateStream -Username "someuser" -OutputDir "D:\Recordings" -MaxRetries 0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Chaturbate username to record')]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [string]$OutputDir = (Join-Path $env:USERPROFILE 'Videos\ChaturbateDownloader'),

        [ValidateSet('best', 'worst', '1080p', '720p', '480p', '360p', '240p')]
        [string]$Quality = 'best',

        [ValidateRange(0, [int]::MaxValue)]
        [int]$MaxRetries = 50,

        [ValidateRange(5, 3600)]
        [int]$RetryDelay = 30,

        [string]$StreamlinkPath,

        [string]$LogFile
    )

    # ── Resolve Streamlink path ──────────────────────────────────────────────
    if (-not $StreamlinkPath) {
        $candidates = @(
            'C:\Program Files\Streamlink\bin\streamlink.exe',
            'C:\Program Files (x86)\Streamlink\bin\streamlink.exe'
        )
        foreach ($c in $candidates) {
            if (Test-Path $c) { $StreamlinkPath = $c; break }
        }
        if (-not $StreamlinkPath) {
            $fromPath = Get-Command streamlink.exe -ErrorAction SilentlyContinue
            if ($fromPath) { $StreamlinkPath = $fromPath.Source }
        }
    }

    if (-not $StreamlinkPath -or -not (Test-Path $StreamlinkPath)) {
        Write-Error "streamlink.exe not found. Please install Streamlink or provide -StreamlinkPath."
        return
    }

    # ── Ensure output directory exists ──────────────────────────────────────
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }

    # ── Resolve log file path ────────────────────────────────────────────────
    if (-not $LogFile) {
        $LogFile = Join-Path $OutputDir "$Username`_downloader.log"
    }

    $streamUrl = "https://chaturbate.com/$Username/"

    Write-StreamLog "=== ChaturbateDownloader v2.0.0 started ===" -Level INFO -LogFile $LogFile
    Write-StreamLog "Username    : $Username"      -Level INFO -LogFile $LogFile
    Write-StreamLog "URL         : $streamUrl"     -Level INFO -LogFile $LogFile
    Write-StreamLog "Output dir  : $OutputDir"     -Level INFO -LogFile $LogFile
    Write-StreamLog "Quality     : $Quality"       -Level INFO -LogFile $LogFile
    Write-StreamLog "Max retries : $(if ($MaxRetries -eq 0) { 'unlimited' } else { $MaxRetries })" -Level INFO -LogFile $LogFile
    Write-StreamLog "Retry delay : ${RetryDelay}s" -Level INFO -LogFile $LogFile
    Write-StreamLog "Log file    : $LogFile"       -Level INFO -LogFile $LogFile

    # ── Retry loop ───────────────────────────────────────────────────────────
    $attempt      = 0
    $successCount = 0

    while ($true) {
        $attempt++

        if ($MaxRetries -gt 0 -and $attempt -gt $MaxRetries) {
            Write-StreamLog "Maximum retries ($MaxRetries) reached. Giving up." -Level ERROR -LogFile $LogFile
            break
        }

        $timestamp   = Get-Date -Format 'yyyyMMdd_HHmmss'
        $outputFile  = Join-Path $OutputDir "$Username`_${timestamp}_seg$('{0:D3}' -f $attempt).mp4"

        Write-StreamLog "--- Attempt $attempt ($(if ($MaxRetries -eq 0) { 'unlimited' } else { "$attempt/$MaxRetries" })) ---" -Level INFO -LogFile $LogFile
        Write-StreamLog "Output file : $outputFile" -Level INFO -LogFile $LogFile

        # Build streamlink arguments
        $slArgs = @(
            $streamUrl,
            $Quality,
            '--output', $outputFile,
            '--hls-live-restart',
            '--retry-streams', '1',
            '--retry-max', '3',
            '--retry-open', '3'
        )

        try {
            $process = Start-Process `
                -FilePath $StreamlinkPath `
                -ArgumentList $slArgs `
                -NoNewWindow `
                -PassThru `
                -Wait

            $exitCode = $process.ExitCode
        }
        catch {
            Write-StreamLog "Failed to start streamlink process: $_" -Level ERROR -LogFile $LogFile
            $exitCode = -1
        }

        # ── Post-process check ───────────────────────────────────────────────
        $fileOk = $false
        if (Test-Path $outputFile) {
            $fileSize = (Get-Item $outputFile).Length
            # Treat files > 1 MB as valid recordings
            if ($fileSize -gt 1MB) {
                $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
                Write-StreamLog "Segment saved: $outputFile ($fileSizeMB MB)" -Level SUCCESS -LogFile $LogFile
                $fileOk = $true
                $successCount++
            }
            else {
                # Remove tiny/empty file artefacts
                Remove-Item $outputFile -Force -ErrorAction SilentlyContinue
            }
        }

        # ── Interpret exit code ──────────────────────────────────────────────
        switch ($exitCode) {
            0 {
                if ($fileOk) {
                    Write-StreamLog "Stream ended normally (exit 0). Segment recorded successfully." -Level SUCCESS -LogFile $LogFile
                }
                else {
                    Write-StreamLog "Stream ended with exit 0 but no valid output file. Stream was likely offline." -Level WARN -LogFile $LogFile
                }
            }
            1 {
                Write-StreamLog "Streamlink exited with error (exit 1). Stream may have dropped or gone offline." -Level WARN -LogFile $LogFile
            }
            default {
                Write-StreamLog "Streamlink exited with unexpected code $exitCode." -Level WARN -LogFile $LogFile
            }
        }

        # ── Decide whether to retry ──────────────────────────────────────────
        $continueRetrying = $true

        if ($exitCode -eq 0 -and $fileOk) {
            # Normal clean end — still retry in case streamer goes live again
            Write-StreamLog "Waiting ${RetryDelay}s before checking if stream resumes..." -Level INFO -LogFile $LogFile
        }
        elseif ($exitCode -eq 0 -and -not $fileOk) {
            Write-StreamLog "Stream appears to be offline. Waiting ${RetryDelay}s before retrying..." -Level WARN -LogFile $LogFile
        }
        else {
            Write-StreamLog "⚠  STREAM DROPPED! Waiting ${RetryDelay}s before reconnecting... (total drops so far: $($attempt - $successCount))" -Level WARN -LogFile $LogFile
        }

        if ($MaxRetries -gt 0 -and $attempt -ge $MaxRetries) {
            Write-StreamLog "No more retries remaining." -Level ERROR -LogFile $LogFile
            $continueRetrying = $false
        }

        if ($continueRetrying) {
            Start-Sleep -Seconds $RetryDelay
        }
        else {
            break
        }
    }

    Write-StreamLog "=== Session complete. Total segments recorded: $successCount ===" -Level SUCCESS -LogFile $LogFile
    Write-StreamLog "Log saved to: $LogFile" -Level INFO -LogFile $LogFile
}
