<#
.SYNOPSIS
Sortiert Verzeichnisse nach einem Regex-Muster in entsprechende Zielordner.

.DESCRIPTION
Dieses Skript durchsucht ein angegebenes Startverzeichnis und sortiert alle Unterordner, deren Namen mit dem angegebenen Regex-Muster übereinstimmen, in Zielordner, die nach dem Muster benannt sind. Die Zielordner werden im angegebenen Startverzeichnis erstellt.

.PARAMETER startdir
Das Startverzeichnis, von dem aus die Ordner sortiert werden sollen. Dies ist ein verpflichtender Parameter.

.PARAMETER Regex
Das Regex-Muster, das zur Identifizierung der zu sortierenden Verzeichnisse verwendet wird. Standardmäßig ist es auf '^\d{4}' gesetzt, um Verzeichnisse zu identifizieren, die mit einer vierstelligen Jahreszahl beginnen.

.EXAMPLE
PS> .\OrganizeFoldersByRegex.ps1 -startdir "n:\"

Dies sortiert alle Unterordner im Verzeichnis "n:\", die mit einer vierstelligen Jahreszahl beginnen, in entsprechende Zielordner, basierend auf dem Standard-Regex-Muster '^\d{4}'.

.EXAMPLE
PS> .\OrganizeFoldersByRegex.ps1 -startdir "n:\" -Regex "^Musik - "

Dies sortiert alle Unterordner im Verzeichnis "n:\", deren Namen mit "Musik - " beginnen, in entsprechende Zielordner.

.NOTES
Autor: Erhard Rainer
Datum: 2022-10-15
Version: 1.1
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$startdir, # Definiere $startdir als verpflichtenden Parameter

    [string]$Regex = '^\d{4}' # Definiere $Regex als optionalen Parameter mit Standardwert
)

# Durchlaufe alle Verzeichnisse im Startverzeichnis
Get-ChildItem -Path $startdir -Directory | ForEach-Object {
    $currentDir = $_
    $dirName = $currentDir.Name

    # Prüfe, ob der Ordnername mit dem Regex-Muster übereinstimmt
    if ($dirName -match $Regex) {
        $match = $Matches[0] # Extrahiere den Treffer aus dem Ordnernamen

        # Zielverzeichnis basierend auf dem Muster "+ [Treffer]" erstellen
        $targetDirName = "+ " + $match
        $targetDir = Join-Path $startdir $targetDirName # Bestimme den vollständigen Pfad des Zielverzeichnisses

        # Erstelle das Zielverzeichnis, falls es nicht existiert
        if (-not (Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory # Erstellung des Zielverzeichnisses, wenn es noch nicht existiert
        }

        # Verschiebe das Verzeichnis in das entsprechende Zielverzeichnis
        $newLocation = Join-Path $targetDir $dirName # Bestimme den neuen Pfad für das aktuelle Verzeichnis
        Move-Item -Path $currentDir.FullName -Destination $newLocation # Verschiebung des Verzeichnisses
    }
}
