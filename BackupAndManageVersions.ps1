<#
.SYNOPSIS
Automatisches Backup und Verwaltung von Verzeichnisversionen.

.DESCRIPTION
Das Skript durchläuft alle Unterverzeichnisse im angegebenen Quellpfad (sourcePath), erstellt ein gepacktes Backup für jedes Verzeichnis, falls Änderungen vorliegen, und speichert diese im Zielverzeichnis (destinationPath). Es behält nur eine definierte Anzahl der neuesten Backup-Versionen und löscht ältere Versionen.

.PARAMETER sourcePath
Der Pfad zum Quellverzeichnis, das die zu sichernden Unterverzeichnisse enthält.

.PARAMETER destinationPath
Der Pfad zum Zielverzeichnis, in dem die gepackten Backup-Dateien gespeichert werden.

.PARAMETER keepVersions
Die Anzahl der Backup-Versionen, die im Zielverzeichnis erhalten bleiben sollen.

.EXAMPLE
PS> .\BackupAndManageVersions.ps1 -sourcePath "W:\" -destinationPath "G:\Meine Ablage\_Programmierung" -keepVersions 5

Erstellt gepackte Backups aller Unterverzeichnisse von W:\, speichert sie in G:\Meine Ablage\_Programmierung\ und behält die letzten 5 Versionen jedes Backups.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$sourcePath,
    
    [Parameter(Mandatory=$true)]
    [string]$destinationPath,
    
    [Parameter(Mandatory=$true)]
    [int]$keepVersions
)

function Pack-Directory {
    param(
        [string]$directoryToPack,
        [string]$destinationZipPath
    )

    $destinationDir = Split-Path -Path $destinationZipPath -Parent
    if (-not (Test-Path -Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir -Force
        Write-Host "Zielverzeichnis erstellt: $destinationDir"
    }
    
    Compress-Archive -Path $directoryToPack -DestinationPath $destinationZipPath -Force
    Write-Host "Verzeichnis gepackt: $directoryToPack nach $destinationZipPath"
}

$sourceDirectories = Get-ChildItem -Path $sourcePath -Directory

foreach ($dir in $sourceDirectories) {
    $latestFile = Get-ChildItem -Path $dir.FullName -File -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($null -ne $latestFile) {
        $latestFileTime = $latestFile.LastWriteTime
        $filter = $dir.Name + "_*.zip"
        $existingBackups = Get-ChildItem -Path $destinationPath -Filter $filter | Sort-Object LastWriteTime -Descending
        
        # Überprüfe, ob ein neueres Backup existiert
        if ($existingBackups.Count -eq 0 -or $existingBackups[0].LastWriteTime -lt $latestFileTime) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $zipFileName = $dir.Name + "_" + $timestamp + ".zip"
            $zipFilePath = Join-Path -Path $destinationPath -ChildPath $zipFileName
            Pack-Directory -directoryToPack $dir.FullName -destinationZipPath $zipFilePath
        } else {
            Write-Host "Aktuelleres Backup existiert bereits für: $($dir.Name)"
        }
        
        # Backup-Versionen verwalten
        if ($existingBackups.Count -gt $keepVersions) {
            $backupsToDelete = $existingBackups | Select-Object -Skip $keepVersions
            foreach ($backup in $backupsToDelete) {
                Remove-Item -Path $backup.FullName -Force
                Write-Host "Altes Backup gelöscht: $($backup.FullName)"
            }
        }
    }
}