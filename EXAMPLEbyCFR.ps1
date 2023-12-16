<#
.SYNOPSIS
Configures the PowerShell environment and sets up various modules, aliases, and key handlers.

.DESCRIPTION
This script imports the necessary modules, configures the PowerShell environment, sets up the SSH client, imports the oh-my-posh module and initializes its configuration, configures aliases for frequently used commands, sets up key handlers for efficient navigation and completion, installs the F7History module for quick access to command history, and configures GUI completion for a visually enhanced experience.

.PARAMETER None
This script does not accept any parameters.

.EXAMPLE
.\EXAMPLEbyCFR.ps1 => profile.ps1
Runs the script to configure the PowerShell environment.

.NOTES
Author: Christian Frischholz
Date: 16.12.2023
Version:0.1.0
git-repo:
#>
# Importiere die benötigten Module
Import-Module PSReadLine
Import-Module Posh-SSH
Import-Module PSCompletions
Import-Module oh-my-posh  # Add this line to import the oh-my-posh module

# Konfiguriere die PowerShell-Umgebung
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellOnKeyPress $false
Set-PSReadLineOption -ColorScheme Dark

# Konfiguriere den SSH-Client
Set-PoshSSHOption -HostKeyCheck $false
Set-PoshSSHOption -UserKnownHostsFile $null
Set-PoshSSHOption -ConnectionTimeout 60

# Importiere das oh-my-posh-Modul und initialisiere die Konfiguration
oh-my-posh init pwsh --config 'C:\Users\chris\scoop\apps\oh-my-posh\current\themes\night-owl.omp.json' | Invoke-Expression

# Konfiguriere Aliase für häufig verwendete Befehle
Set-Alias ci code-insiders
Set-Alias bg Bginfo64
Set-Alias st C:\Users\chris\speedtest.exe
Set-Alias a2 aria2c
Set-Alias yt yt-dlp
Set-Alias py python
Set-Alias mplayer mpv
Set-Alias far C:\Program Files\Far Manager\Far.exe

# Konfiguriere Tastenkürzel für effiziente Navigation und Vervollständigung
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Smart Quote-Einfügefunktion für konsistente Syntax
Set-PSReadLineKeyHandler -Chord '"',"'" -BriefDescription SmartInsertQuote -LongDescription "Insert paired quotes if not already on a quote" -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line.Length -gt $cursor -and $line[$cursor] -eq $key.KeyChar) {
        # Move cursor to next character
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else {
        # Insert matching quotes and position cursor between them
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)" * 2)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
    }
}

Import-Module PSReadline
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) .ps_history
Register-EngineEvent PowerShell.Exiting -Action { Get-History | Export-Clixml $HistoryFilePath } | out-null
if (Test-path $HistoryFilePath) { Import-Clixml $HistoryFilePath | Add-History }
# if you don't already have this configured...
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Importiere das F7History-Modul für schnellen Zugriff auf die Befehlshistorie
Install-Module -Name "F7History"
Import-Module -Name "F7History" -ArgumentList @{Key = "F10"; AllKey = "Shift-F10"}

# Konfiguriere GUI-Vervollständigung für eine visuellere Erfahrung
Install-GuiCompletion
$GuiCompletionConfig.DoubleBorder = $false
$GuiCompletionConfig.ScrollDisplayDown = $false
