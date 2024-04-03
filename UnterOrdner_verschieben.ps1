param (
    [string]$QuellVerzeichnis = "y:\_Filme\",
    [string]$ZielVerzeichnis = "n:\",
    [string]$regexPattern = "^\d{4} -" # Optionaler Parameter, Standardwert für vierstellige Jahreszahl gefolgt von " - "
)

# Ermitteln der Gesamtgröße der zu verschiebenden Verzeichnisse
$unterVerzeichnisse = Get-ChildItem -Path $QuellVerzeichnis -Directory | Where-Object { [string]::IsNullOrWhiteSpace($regexPattern) -or $_.Name -match $regexPattern }
$gesamtGroesse = 0
foreach ($verz in $unterVerzeichnisse) {
    $gesamtGroesse += (Get-ChildItem -Path $verz.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
}
Write-Host "Gesamtgröße der zu verschiebenden Ordner: $($gesamtGroesse / 1GB) GB"

$gesamtVerschoben = 0
$gesamtDauer = 0
$verbleibendeVerzeichnisse = $unterVerzeichnisse.Count

foreach ($unterVerz in $unterVerzeichnisse) {
    # Überprüfen, ob das Verzeichnis leer ist
    $inhalt = Get-ChildItem -Path $unterVerz.FullName
    if ($inhalt.Length -eq 0) {
        Write-Host "Das Verzeichnis $($unterVerz.FullName) ist leer und wird nicht verschoben."
        continue
    }

    $startZeit = Get-Date
    $verzeichnisGroesse = (Get-ChildItem -Path $unterVerz.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $zielPfad = Join-Path -Path $ZielVerzeichnis -ChildPath $unterVerz.Name
    $neuerName = $unterVerz.Name
    $version = 2

    while (Test-Path -Path $zielPfad) {
        $neuerName = "$($unterVerz.Name) V$version"
        $zielPfad = Join-Path -Path $ZielVerzeichnis -ChildPath $neuerName
        $version++
    }

    if ($neuerName -ne $unterVerz.Name) {
        Write-Host "Ordner '$($unterVerz.Name)' existiert bereits. Umbenennen in '$neuerName'"
    }
    Write-Host "Verschiebe von '$($unterVerz.FullName)' nach '$zielPfad'"
    $dauer = (Measure-Command {
        Move-Item -Path $unterVerz.FullName -Destination $zielPfad
    }).TotalSeconds
    $gesamtDauer += $dauer
    $gesamtVerschoben += $verzeichnisGroesse

    $durchschnittsRate = $gesamtVerschoben / $gesamtDauer
    $verbleibendeGroesse = $gesamtGroesse - $gesamtVerschoben
    $geschaetzteRestzeit = $verbleibendeGroesse / $durchschnittsRate

    Write-Host "     Transferiert: $($verzeichnisGroesse / 1MB) MB, Dauer: $($dauer / 60) Minuten"
    Write-Host "     Aktuelle Transferrate: $($durchschnittsRate / 1MB) MB/s, geschätzte verbleibende Zeit: $($geschaetzteRestzeit / 60) Minuten für $($verbleibendeGroesse / 1MB) MB."
    $verbleibendeVerzeichnisse--
}

$gesamtDauerInMinuten = $gesamtDauer / 60
$endRate = $gesamtVerschoben / $gesamtDauer
Write-Host "--------------------------"
Write-Host "Gesamtdauer: $gesamtDauerInMinuten Minuten, Durchschnittliche Transferrate: $($endRate / 1MB) MB/s"
