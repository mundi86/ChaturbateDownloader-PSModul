@{
    ModuleVersion     = '2.0.1'
    GUID              = 'a3f1c2e4-5b67-4d89-a012-bc3def456789'
    Author            = 'mundi'
    CompanyName       = 'mundi'
    Copyright         = '(c) 2024-2026 mundi. MIT License.'
    Description       = 'PowerShell module for downloading Chaturbate streams with auto-reconnect and timestamped logging.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-ChaturbateStream')
    PrivateData       = @{
        PSData = @{
            Tags       = @('Chaturbate', 'Stream', 'Downloader', 'Streamlink', 'Recording')
            LicenseUri = 'https://github.com/mundi86/ChaturbateDownloader-PSModul/blob/main/LICENSE'
            ProjectUri = 'https://github.com/mundi86/ChaturbateDownloader-PSModul'
        }
    }
}
