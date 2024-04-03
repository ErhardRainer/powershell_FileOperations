<#
.SYNOPSIS
Dieses Skript benennt Verzeichnisse um, die .rar Dateien enthalten, indem es "[uv]" zum Verzeichnisnamen hinzufügt.

.DESCRIPTION
Das Skript durchsucht rekursiv ein angegebenes Startverzeichnis nach Unterverzeichnissen, die .rar Dateien enthalten. Verzeichnisse, die diese Kriterien erfüllen, werden umbenannt, indem "[uv]" an den Namen angehängt wird.

.AUTHOR
Erhard Rainer
http://erhard-rainer.com

.DATE
2024-04-03

.EXAMPLE
PS> .\Rename_Folder.ps1 -StartDirectory "J:\"

.PARAMETER StartDirectory
Das Startverzeichnis, von dem aus die Suche beginnen soll.

.VERSIONHISTORY
2024-04-03 - 1.0  - Erste Version

.NOTES
Lizenz: Creative Commons Attribution 4.0 International License (CC BY 4.0)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$StartDirectory # Definiert den Übergabeparameter für das Startverzeichnis
)

# Rekursives Durchlaufen aller Unterverzeichnisse im angegebenen Startverzeichnis
Get-ChildItem -Path $StartDirectory -Directory | ForEach-Object {
    $directory = $_ # Aktuelles Verzeichnis in der Schleife
    $rarFiles = Get-ChildItem -Path $directory.FullName -Filter "*.rar" -Recurse # Sucht nach .rar Dateien im aktuellen Verzeichnis und dessen Unterverzeichnissen

    # Überprüfen, ob im aktuellen Verzeichnis .rar Dateien vorhanden sind
    if ($rarFiles.Count -gt 0) {
        $newDirectoryName = $directory.FullName + " [uv]" # Neuer Name für das Verzeichnis

        # Vorbereitung zum Umbenennen des Verzeichnisses
        $sourceName = $directory.FullName
        Write-Host "Benenne Verzeichnis $sourceName in $newDirectoryName um."
        # Rename-Item -Path $directory.FullName -NewName $newDirectoryName # Umbenennen des Verzeichnisses
        # Write-Host "Verzeichnis umbenannt: $newDirectoryName"
    }
}

Write-Host "Verarbeitung abgeschlossen."