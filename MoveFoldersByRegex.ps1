<#
.SYNOPSIS
Dieses Skript verschiebt Verzeichnisse basierend auf einem Regex-Muster von einem Quell- zu einem Zielverzeichnis.

.DESCRIPTION
Das Skript filtert Verzeichnisse im Quellverzeichnis basierend auf einem optionalen Regex-Muster, das vierstellige Jahreszahlen am Anfang des Verzeichnisnamens identifiziert. Es berechnet die Gesamtgröße der zu verschiebenden Verzeichnisse, verschiebt sie dann einzeln und gibt währenddessen Informationen über den Fortschritt aus.

.AUTHOR
Erhard Rainer
http://erhard-rainer.com

.DATE
2024-04-03

.EXAMPLE
PS> .\MMoveFoldersByRegex.ps1 -QuellVerzeichnis "y:\_Filme\" -ZielVerzeichnis "n:\" -regexPattern "^\d{4} -"

.PARAMETER QuellVerzeichnis
Das Verzeichnis, von dem aus die Dateien verschoben werden sollen.

.PARAMETER ZielVerzeichnis
Das Zielverzeichnis, in das die Dateien verschoben werden sollen.

.PARAMETER regexPattern
Ein optionales Regex-Muster, das verwendet wird, um zu bestimmen, welche Verzeichnisse verschoben werden sollen. Standardmäßig sucht es nach einer vierstelligen Jahreszahl am Anfang des Namens.

.VERSIONHISTORY
2024-04-03 - 1.0  - Erste Version

.NOTES
Lizenz: Creative Commons Attribution 4.0 International License (CC BY 4.0)
#>

param (
    [string]$QuellVerzeichnis = "y:\_Filme\",
    [string]$ZielVerzeichnis = "n:\",
    [string]$regexPattern = "^\d{4} -" # Standardmäßiger optionaler Parameter für Regex-Muster
)

# Ermitteln der Gesamtgröße der zu verschiebenden Verzeichnisse
$unterVerzeichnisse = Get-ChildItem -Path $QuellVerzeichnis -Directory | Where-Object { [string]::IsNullOrWhiteSpace($regexPattern) -or $_.Name -match $regexPattern }
$gesamtGroesse = 0
foreach ($verz in $unterVerzeichnisse) {
    $gesamtGroesse += (Get-ChildItem -Path $verz.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
}
Write-Host "Gesamtgröße der zu verschiebenden Ordner: $($gesamtGroesse / 1GB) GB"

# Initialisierung von Variablen für den Gesamtfortschritt
$gesamtVerschoben = 0
$gesamtDauer = 0
$verbleibendeVerzeichnisse = $unterVerzeichnisse.Count

foreach ($unterVerz in $unterVerzeichnisse) {
    # Überprüfung auf leere Verzeichnisse
    $inhalt = Get-ChildItem -Path $unterVerz.FullName
    if ($inhalt.Length -eq 0) {
        Write-Host "Das Verzeichnis $($unterVerz.FullName) ist leer und wird nicht verschoben."
        continue
    }

    # Beginn der Verschiebung
    $startZeit = Get-Date
    $verzeichnisGroesse = (Get-ChildItem -Path $unterVerz.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $zielPfad = Join-Path -Path $ZielVerzeichnis -ChildPath $unterVerz.Name
    $neuerName = $unterVerz.Name
    $version = 2

    # Umbenennen bei Namenskonflikten
    while (Test-Path -Path $zielPfad) {
        $neuerName = "$($unterVerz.Name) V$version"
        $zielPfad = Join-Path -Path $ZielVerzeichnis -ChildPath $neuerName
        $version++
    }

    if ($neuerName -ne $unterVerz.Name) {
        Write-Host "Ordner '$($unterVerz.Name)' existiert bereits. Umbenennen in '$neuerName'"
    }
    Write-Host "Verschiebe von '$($unterVerz.FullName)' nach '$zielPfad'"
    # Berechnung der Verschiebungszeit
    $dauer = (Measure-Command {
        Move-Item -Path $unterVerz.FullName -Destination $zielPfad
    }).TotalSeconds
    $gesamtDauer += $dauer
    $gesamtVerschoben += $verzeichnisGroesse

    # Berechnung der Durchschnittsrate und geschätzten Restzeit
    $durchschnittsRate = $gesamtVerschoben / $gesamtDauer
    $verbleibendeGroesse = $gesamtGroesse - $gesamtVerschoben
    $geschaetzteRestzeit = $verbleibendeGroesse / $durchschnittsRate

    Write-Host "     Transferiert: $($verzeichnisGroesse / 1MB) MB, Dauer: $($dauer / 60) Minuten"
    Write-Host "     Aktuelle Transferrate: $($durchschnittsRate / 1MB) MB/s, geschätzte verbleibende Zeit: $($geschaetzteRestzeit / 60) Minuten für $($verbleibendeGroesse / 1MB) MB."
    $verbleibendeVerzeichnisse--
}

# Abschlussbericht
$gesamtDauerInMinuten = $gesamtDauer / 60
$endRate = $ges