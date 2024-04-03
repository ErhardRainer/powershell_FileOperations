<#
.SYNOPSIS
Analysiert und optional löscht Dateien in einem Zielverzeichnis basierend auf ihrer Häufigkeit.

.DESCRIPTION
Dieses Skript durchläuft rekursiv alle Dateien in einem angegebenen Zielverzeichnis, zählt, wie oft jede Datei vorkommt, und zeigt Dateien an, die öfter als ein bestimmter Schwellenwert vorhanden sind. Optional können diese Dateien automatisch gelöscht werden.

.PARAMETER Zielverzeichnis
Das Verzeichnis, in dem die Dateien analysiert (und optional gelöscht) werden sollen. Dies ist ein verpflichtender Parameter.

.PARAMETER delete
Ein optionaler Boolean-Parameter, der bestimmt, ob Dateien, die öfter als der Schwellenwert vorkommen, gelöscht werden sollen. Standardmäßig auf $false gesetzt.

.PARAMETER Anzahl
Der Schwellenwert für die Anzahl der Vorkommen einer Datei, ab der Aktionen ergriffen werden (Anzeige oder Löschung). Standardmäßig auf 2 gesetzt.

.EXAMPLE
<#
.SYNOPSIS
Analysiert und optional löscht Dateien in einem Zielverzeichnis basierend auf ihrer Häufigkeit.

.DESCRIPTION
Dieses Skript durchläuft rekursiv alle Dateien in einem angegebenen Zielverzeichnis, zählt, wie oft jede Datei vorkommt, und zeigt Dateien an, die öfter als ein bestimmter Schwellenwert vorhanden sind. Optional können diese Dateien automatisch gelöscht werden.

.PARAMETER Zielverzeichnis
Das Verzeichnis, in dem die Dateien analysiert (und optional gelöscht) werden sollen. Dies ist ein verpflichtender Parameter.

.PARAMETER delete
Ein optionaler Boolean-Parameter, der bestimmt, ob Dateien, die öfter als der Schwellenwert vorkommen, gelöscht werden sollen. Standardmäßig auf $false gesetzt.

.PARAMETER Anzahl
Der Schwellenwert für die Anzahl der Vorkommen einer Datei, ab der Aktionen ergriffen werden (Anzeige oder Löschung). Standardmäßig auf 2 gesetzt.

.EXAMPLE
PS> .\ScriptName.ps1 -Zielverzeichnis "n:\_neu\" -delete $true -Anzahl 2

.NOTES
Version: 1.0
Autor: Erhard Rainer
Datum: 2021-05-16
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$Zielverzeichnis, # Definiert das Zielverzeichnis als verpflichtenden Parameter

    [bool]$delete = $false, # Definiert, ob Dateien gelöscht werden sollen, als optionalen Parameter

    [int]$Anzahl = 2 # Definiert den Schwellenwert für die Anzahl der Vorkommen als optionalen Parameter
)

# Rekursives Sammeln aller Dateien im Zielverzeichnis
$alleDateien = Get-ChildItem -Path $Zielverzeichnis -Recurse -File

# Erstellen einer Hashtabelle zur Speicherung der Häufigkeiten jeder Datei
$dateiHaeufigkeiten = @{}

# Durchlaufen aller Dateien und Zählen ihrer Vorkommen
foreach ($datei in $alleDateien) {
    $dateiname = $datei.Name
    if ($dateiHaeufigkeiten.ContainsKey($dateiname)) {
        $dateiHaeufigkeiten[$dateiname]++
    } else {
        $dateiHaeufigkeiten[$dateiname] = 1
    }
}

# Erstellen einer Liste von PSCustomObjects mit Dateinamen und deren Anzahl
$dateiListe = foreach ($item in $dateiHaeufigkeiten.GetEnumerator()) {
    [PSCustomObject]@{
        Dateiname = $item.Key
        Anzahl = $item.Value
    }
}

# Ausgabe der Dateien, die öfter als der Schwellenwert vorkommen, sortiert nach ihrer Anzahl
$dateiListe | Where-Object { $_.Anzahl -gt $Anzahl } | Sort-Object Anzahl -Descending | Format-Table -AutoSize

# Optional: Löschen von Dateien, die öfter als der Schwellenwert vorkommen
if ($delete) {
    $dateiListe | Where-Object { $_.Anzahl -gt $Anzahl } | ForEach-Object {
        $dateiname = $_.Dateiname

        # Finde alle Dateien mit diesem Namen und lösche sie
        Get-ChildItem -Path $Zielverzeichnis -Recurse -File -Filter $dateiname | ForEach-Object {
            Write-Host "Lösche Datei: $($_.FullName)"
            Remove-Item -Path $_.FullName -Force
        }
    }
}


.NOTES
Version: 1.0
Autor: [Autor entfernt]
Datum: [Datum entfernt]
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$Zielverzeichnis, # Definiert das Zielverzeichnis als verpflichtenden Parameter

    [bool]$delete = $false, # Definiert, ob Dateien gelöscht werden sollen, als optionalen Parameter

    [int]$Anzahl = 2 # Definiert den Schwellenwert für die Anzahl der Vorkommen als optionalen Parameter
)

# Rekursives Sammeln aller Dateien im Zielverzeichnis
$alleDateien = Get-ChildItem -Path $Zielverzeichnis -Recurse -File

# Erstellen einer Hashtabelle zur Speicherung der Häufigkeiten jeder Datei
$dateiHaeufigkeiten = @{}

# Durchlaufen aller Dateien und Zählen ihrer Vorkommen
foreach ($datei in $alleDateien) {
    $dateiname = $datei.Name
    if ($dateiHaeufigkeiten.ContainsKey($dateiname)) {
        $dateiHaeufigkeiten[$dateiname]++
    } else {
        $dateiHaeufigkeiten[$dateiname] = 1
    }
}

# Erstellen einer Liste von PSCustomObjects mit Dateinamen und deren Anzahl
$dateiListe = foreach ($item in $dateiHaeufigkeiten.GetEnumerator()) {
    [PSCustomObject]@{
        Dateiname = $item.Key
        Anzahl = $item.Value
    }
}

# Ausgabe der Dateien, die öfter als der Schwellenwert vorkommen, sortiert nach ihrer Anzahl
$dateiListe | Where-Object { $_.Anzahl -gt $Anzahl } | Sort-Object Anzahl -Descending | Format-Table -AutoSize

# Optional: Löschen von Dateien, die öfter als der Schwellenwert vorkommen
if ($delete) {
    $dateiListe | Where-Object { $_.Anzahl -gt $Anzahl } | ForEach-Object {
        $dateiname = $_.Dateiname

        # Finde alle Dateien mit diesem Namen und lösche sie
        Get-ChildItem -Path $Zielverzeichnis -Recurse -File -Filter $dateiname | ForEach-Object {
            Write-Host "Lösche Datei: $($_.FullName)"
            Remove-Item -Path $_.FullName -Force
        }
    }
}
