# 🎬 ChaturbateDownloader

> A PowerShell module that records Chaturbate live streams using [Streamlink](https://streamlink.github.io/) — with **automatic reconnect** when a stream drops, color-coded console output, and timestamped log files.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Streamlink 1.7+](https://img.shields.io/badge/Streamlink-1.7%2B-orange.svg)](https://streamlink.github.io/)

--- 

## 📖 Description

**ChaturbateDownloader** is a PowerShell module that wraps Streamlink to continuously record a Chaturbate stream.  
The key feature is **resilience**: if a stream drops or the connection is interrupted, the module automatically waits and reconnects — up to a configurable number of retries. You'll never miss a stream drop silently again.

### ✨ Features

- 🔄 **Auto-reconnect** — automatically retries after stream drops or network errors
- 🎨 **Color-coded console output** — green = success, yellow = warning, red = error
- 📝 **Timestamped log file** — every event logged with `[yyyy-MM-dd HH:mm:ss]`
- 📁 **Segmented recordings** — each reconnect creates a new file (no data overwritten)
- ⚙️ **Fully configurable** — output directory, quality, retries, delay, paths
- 🔍 **Exit code detection** — distinguishes normal stream end from unexpected drops
- 🔎 **Auto-detects Streamlink** — searches common install paths and `$PATH`

---

## 📦 Prerequisites

| Requirement | Version | Link |
|-------------|---------|------|
| PowerShell | 5.1 or newer | [Download](https://github.com/PowerShell/PowerShell/releases) |
| Streamlink | 1.7.0 or newer | [Download](https://streamlink.github.io/install.html) |

> ⚠️ The `streamlink-1.7.0.exe` binary is **not** included in this repository to keep it small.  
> Download Streamlink from the [official website](https://streamlink.github.io/install.html) and install it before running the installer.

---

## 🚀 Installation

### Step 1 — Install Streamlink

Download and install Streamlink 1.7.0 or newer from:  
👉 https://streamlink.github.io/install.html

### Step 2 — Run the Installer

Open **PowerShell as Administrator** and run:

```powershell
.\Install-ChaturbateDownloader.ps1
```

The installer will:
1. ✅ Verify Streamlink is installed and meets the version requirement
2. ✅ Set the Execution Policy to `RemoteSigned` for the current user
3. ✅ Copy the module files to `C:\Program Files\WindowsPowerShell\Modules\ChaturbateDownloader\`
4. ✅ Copy `chaturbate.py` to the Streamlink plugin directory
5. ✅ Import the module automatically

#### Custom paths (optional)

```powershell
.\Install-ChaturbateDownloader.ps1 `
    -ModuleDir "C:\MyModules\ChaturbateDownloader" `
    -PluginDir "C:\CustomStreamlink\plugins" `
    -StreamlinkPath "C:\Tools\streamlink.exe"
```

### Step 3 — (Optional) Permanent Import

To load the module automatically in every new PowerShell session:

```powershell
# Open your profile script
notepad $PROFILE

# Add this line at the end:
Import-Module "C:\Program Files\WindowsPowerShell\Modules\ChaturbateDownloader\ChaturbateDownloader.psm1"
```

---

## 💻 Usage

### Basic usage

```powershell
Get-ChaturbateStream -Username "someuser"
```

This records the stream at best quality, auto-reconnects up to 50 times with 30-second delays between retries, and saves the output to `~\Videos\ChaturbateDownloader\`.

### With options

```powershell
Get-ChaturbateStream `
    -Username   "someuser" `
    -OutputDir  "D:\Recordings" `
    -Quality    "720p" `
    -MaxRetries 10 `
    -RetryDelay 60
```

### Unlimited retries (run until you stop it manually)

```powershell
Get-ChaturbateStream -Username "someuser" -MaxRetries 0
```

### Custom Streamlink path

```powershell
Get-ChaturbateStream -Username "someuser" -StreamlinkPath "C:\Tools\streamlink.exe"
```

---

## ⚙️ Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Username` | `string` | **required** | Chaturbate username to record |
| `-OutputDir` | `string` | `~\Videos\ChaturbateDownloader` | Directory where recordings are saved |
| `-Quality` | `string` | `best` | Stream quality: `best`, `worst`, `1080p`, `720p`, `480p`, `360p`, `240p` |
| `-MaxRetries` | `int` | `50` | Max reconnect attempts (0 = unlimited) |
| `-RetryDelay` | `int` | `30` | Seconds to wait between retries (5–3600) |
| `-StreamlinkPath` | `string` | auto-detect | Full path to `streamlink.exe` |
| `-LogFile` | `string` | `<OutputDir>\<user>_downloader.log` | Path for the log file |

---

## 📝 Logging

Every event is logged to:
- **Console** — color-coded in real time
- **Log file** — `<OutputDir>\<Username>_downloader.log`

### Log format

```
[2026-03-12 19:45:23] [INFO]    === ChaturbateDownloader v2.0.0 started ===
[2026-03-12 19:45:23] [INFO]    Username    : someuser
[2026-03-12 19:45:23] [INFO]    Attempt 1 (1/50)
[2026-03-12 19:45:23] [INFO]    Output file : D:\Recordings\someuser_20260312_194523_seg001.mp4
[2026-03-12 19:52:11] [SUCCESS] Segment saved: someuser_20260312_194523_seg001.mp4 (243.7 MB)
[2026-03-12 19:52:11] [WARN]    ⚠ STREAM DROPPED! Waiting 30s before reconnecting... (total drops so far: 1)
[2026-03-12 19:52:41] [INFO]    Attempt 2 (2/50)
```

### Console colors

| Color | Level | Meaning |
|-------|-------|---------|
| 🔵 Cyan | INFO | General status information |
| 🟡 Yellow | WARN | Stream dropped, retrying |
| 🔴 Red | ERROR | Fatal error, giving up |
| 🟢 Green | SUCCESS | Recording saved successfully |

---

## 📁 Project Structure

```
ChaturbateDownloader/
├── .gitignore                          # Git ignore rules
├── LICENSE                             # MIT License
├── README.md                           # This file
├── ChaturbateDownloader.psd1           # PowerShell module manifest (v2.0.0)
├── ChaturbateDownloader.psm1           # Module - Get-ChaturbateStream function
├── Install-ChaturbateDownloader.ps1    # Installer script
└── source/
    └── chaturbate.py                   # Streamlink plugin for Chaturbate
```

---

## 🔧 Troubleshooting

### ❓ streamlink.exe not found

Make sure Streamlink is installed. The module searches:
- `C:\Program Files\Streamlink\bin\streamlink.exe`
- `C:\Program Files (x86)\Streamlink\bin\streamlink.exe`
- Any location in your system `PATH`

Or pass the path explicitly with `-StreamlinkPath`.

### ❓ Stream always shows as offline / no file recorded

- Verify the username is correct and the stream is currently live
- Check the log file for API response details
- Ensure `chaturbate.py` has been copied to the Streamlink plugin directory (re-run the installer)

### ❓ Execution Policy error

Run PowerShell as Administrator and execute:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### ❓ Recordings are very short / under 1 MB

Files under 1 MB are automatically removed and treated as failed attempts. This threshold can indicate the stream was briefly available but dropped immediately — the retry loop will handle reconnecting.

---

## 🤝 Contributing

Pull requests and issues are welcome. Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "Add my feature"`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

© 2024 myCode
