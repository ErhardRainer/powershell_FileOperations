<#
.SYNOPSIS
Sortiert Verzeichnisse nach dem Jahr im Namen in entsprechende Jahresordner.

.DESCRIPTION
Dieses Skript durchsucht ein angegebenes Startverzeichnis und sortiert alle Unterordner, deren Namen mit einer vierstelligen Jahreszahl beginnen, in Zielordner, die nach diesen Jahren benannt sind. Die Zielordner werden im Format "+ [Jahr]" erstellt und befinden sich im selben Startverzeichnis.

.PARAMETER startdir
Das Startverzeichnis, von dem aus die Ordner sortiert werden sollen. Dies ist ein verpflichtender Parameter.

.EXAMPLE
PS> .\nachJahrenSortieren.ps1 -startdir "n:\"

.NOTES
Autor: Erhard Rainer
Datum: 2022-10-15
Version: 1.0
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$startdir # Definiere $startdir als verpflichtenden Parameter
)

# Durchlaufe alle Verzeichnisse im Startverzeichnis
Get-ChildItem -Path $startdir -Directory | ForEach-Object {
    $currentDir = $_
    $dirName = $currentDir.Name

    # Prüfe, ob der Ordnername mit einer vierstelligen Zahl beginnt
    if ($dirName -match '^\d{4}') {
        $year = $Matches[0] # Extrahiere die Jahreszahl aus dem Ordnernamen

        # Zielverzeichnis basierend auf dem Muster "+ [Jahr]" erstellen
        $targetDirName = "+ " + $year
        $targetDir = Join-Path $startdir $targetDirName # Bestimme den vollständigen Pfad des Zielverzeichnisses

        # Erstelle das Zielverzeichnis, falls es nicht existiert
        if (-not (Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory # Erstellung des Zielverzeichnisses, wenn es noch nicht existiert
        }

        # Verschiebe das Verzeichnis in das entsprechende Jahresverzeichnis
        $newLocation = Join-Path $targetDir $dirName # Bestimme den neuen Pfad für das aktuelle Verzeichnis
        Move-Item -Path $currentDir.FullName -Destination $newLocation # Verschiebung des Verzeichnisses
    }
}