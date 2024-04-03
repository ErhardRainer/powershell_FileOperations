<#
.SYNOPSIS
Organisiert Dateien in einem Verzeichnis, indem es sie in Unterordner basierend auf einer festgelegten Anzahl sortiert.

.DESCRIPTION
Dieses Skript nimmt einen Startpfad und eine Dateianzahl entgegen. Es sortiert Dateien im Startpfad in neu erstellte Unterordner, wobei jeder Unterordner eine spezifische Anzahl von Dateien enthält. Dateinamen werden vor dem Verschieben sanitisiert, um ungültige Zeichen zu entfernen.

.PARAMETER startPath
Der Pfad, von dem aus die Dateien organisiert werden sollen. Standardmäßig auf "i:\" gesetzt.

.PARAMETER filesCount
Die maximale Anzahl von Dateien pro Unterordner. Standardmäßig auf 150 gesetzt.

.EXAMPLE
PS> .\großeVerzeichnisseAufteilen.ps1 -startPath "i:\" -filesCount 150

.NOTES
Autor: Erhard Rainer
Datum: 2023-12-10
Version: 1.0

#>

param (
    [string]$startPath = "i:\",
    [int]$filesCount = 150
)

function Sanitize-FileName($fileName) {
    # Entfernt ungültige Zeichen aus Dateinamen
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    return $fileName -replace $re, ''
}

# Prüft, ob der angegebene Startpfad existiert
if (-not (Test-Path -Path $startPath)) {
    Write-Error "Der angegebene Pfad existiert nicht."
    return
}

# Holt alle Dateien im Startpfad und sortiert sie nach dem Erstellungsdatum
Write-Host "Scanne das Verzeichnis: $startPath"
$allFiles = Get-ChildItem -Path $startPath -File | Sort-Object CreationTime

# Erstellt eine Liste der tatsächlich vorhandenen Dateien
$existingFiles = @()
foreach ($file in $allFiles) {
    if (Test-Path -Path $file.FullName) {
        $existingFiles += $file
    } else {
        Write-Warning "Datei $($file.FullName) wurde nicht gefunden und wird übersprungen."
    }
}

# Erstellt Unterordner und verschiebt Dateien
$folderIndex = 1
while ($existingFiles.Count -gt 0) {
    $folderName = "{0:D4}" -f $folderIndex
    $folderPath = Join-Path -Path $startPath -ChildPath $folderName
    
    # Prüft, ob der Unterordner existiert und wie viele Dateien darin verschoben werden sollen
    if (Test-Path -Path $folderPath) {
        $existingFilesInFolder = (Get-ChildItem -Path $folderPath -File).Count
        $filesToMove = $filesCount - $existingFilesInFolder
        if ($filesToMove -le 0) {
            Write-Host "Verzeichnis $folderPath ist bereits voll."
            $folderIndex++
            continue
        }
    } else {
        New-Item -Path $folderPath -ItemType Directory
        $filesToMove = $filesCount
    }

    Write-Host "Befülle Verzeichnis $folderPath"
    $filesToProcess = $existingFiles[0..($filesToMove - 1)]
    foreach ($file in $filesToProcess) {
        $sanitizedFileName = Sanitize-FileName($file.Name)
        $destinationPath = Join-Path -Path $folderPath -ChildPath $sanitizedFileName
        
        # Verschiebt die Datei, falls sie im Zielverzeichnis noch nicht existiert
        if (-not (Test-Path -Path $destinationPath)) {
            Move-Item -Path $file.FullName -Destination $destinationPath
        } else {
            Write-Warning "Eine Datei mit dem Namen $sanitizedFileName existiert bereits im Zielverzeichnis und wurde übersprungen."
        }
    }

    # Aktualisiert die Liste der zu verarbeitenden Dateien
    $existingFiles = $existingFiles[$filesToMove..$existingFiles.Count]
    $folderIndex++
}
