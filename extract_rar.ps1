<#
.SYNOPSIS
Entpackt RAR-Dateien in vorgegebenen Verzeichnissen automatisch mit 7-Zip.

.DESCRIPTION
Das Skript `extract_rar.ps1` durchsucht eine Reihe von Startverzeichnissen nach RAR-Dateien, speziell nach Teilen von mehrteiligen RAR-Archiven, und entpackt diese. Es wird überprüft, ob die Größe des Verzeichnisses nach dem Entpacken wie erwartet gestiegen ist. Falls ja, werden die RAR-Dateien optional gelöscht.

.NAME
extract_rar.ps1

.AUTHOR
Erhard Rainer

.DATE
2023-09-16

.EXAMPLE
PS> .\extract_rar.ps1 -startdirs @("j:\Path\To\Series\S01\", "j:\Path\To\Series\S02\") -PfadZu7Zip "C:\Program Files\7-Zip\7z.exe" -password "yourpassword"

.PARAMETER startdirs
Die Startverzeichnisse, in denen nach RAR-Dateien gesucht werden soll.

.PARAMETER PfadZu7Zip
Der Pfad zur 7-Zip-Exe-Datei. Optional, Standard ist "C:\Program Files\7-Zip\7z.exe".

.PARAMETER password
Das Passwort für die RAR-Dateien, falls erforderlich. Optional.

.VERSIONHISTORY
2023-09-16 - Initiale Version

.NOTES
Lizenz: Creative Commons Attribution 4.0 International License (CC BY 4.0)
#>

param (
    [Parameter(Mandatory=$true)]
    [string[]]$startdirs,

    [string]$PfadZu7Zip = "C:\Program Files\7-Zip\7z.exe",

    [string]$password
)

# Funktion, um die Größe eines Verzeichnisses in GB zu ermitteln
function Get-DirectorySize {
    param (
        [string]$Path
    )
    (Get-ChildItem -Path $Path -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1GB
}

foreach ($startdir in $startdirs) {
    # Suche nach allen .part1.rar und .part01.rar Dateien
    $filesToExtract = Get-ChildItem -Path $startdir -Recurse -Filter "*.part*.rar" |
                      Where-Object { $_.Name -match "part1\.rar$|part01\.rar$" }

    # Falls keine mehrteiligen Dateien gefunden, Suche nach einfachen .rar Dateien
    if (-not $filesToExtract) {
        $filesToExtract = Get-ChildItem -Path $startdir -Recurse -Filter "*.rar" |
                          Where-Object { $_.Name -match "\.rar$" -and $_.Name -notmatch "part\d+\.rar$" }
    }

    foreach ($file in $filesToExtract) {
        $directory = $file.DirectoryName
        Write-Host "Verzeichnis: $directory" -BackgroundColor Red
        $baseName = $file.BaseName -replace "part1$|part01$", "part*"

        # Suche nach allen .part*.rar Dateien basierend auf dem Basisnamen
        $partFiles = Get-ChildItem -Path $directory -Filter "$baseName.rar"
        $partFilesSize = (($partFiles | Measure-Object -Property Length -Sum).Sum / 1GB)

        $initialSize = Get-DirectorySize -Path $directory

        # Starte den Entpackungsprozess
        Write-Host "Entpacke $($file.FullName)"
        $arguments = "x", "`"$($file.FullName)`"", "-o`"$directory`"", "-aoa"

        if (-not [string]::IsNullOrWhiteSpace($password)) {
            $arguments += "-p$password"
        }

        Start-Process -FilePath $PfadZu7Zip -ArgumentList $arguments -Wait

        $finalSize = Get-DirectorySize -Path $directory

        # Prüfung auf erfolgreiche Vergrößerung des Verzeichnisses
        Write-Host "FileSize initial: $initialSize GB"
        Write-Host "FileSize part.rar: $partFilesSize GB"
        Write-Host "FileSize final: $finalSize GB"
        if ($finalSize -gt ($initialSize + $partFilesSize)) {
            Write-Host "Erfolgreich entpackt und verifiziert. Bereit zum Löschen der .part*.rar Dateien."
            # $partFiles | Remove-Item -Force
        } else {
            Write-Host "Verzeichnisgröße $directory nicht wie erwartet gewachsen: $initialSize + $partFilesSize < $finalSize GB"
        }
    }
}