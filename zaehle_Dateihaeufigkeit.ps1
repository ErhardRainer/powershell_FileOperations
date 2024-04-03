# Zielverzeichnis festlegen
$Zielverzeichnis = "n:\_neu\" # Ändern Sie dies zu Ihrem Zielverzeichnis
$delte = $true

# Rekursives Sammeln aller Dateien
$alleDateien = Get-ChildItem -Path $Zielverzeichnis -Recurse -File

# Erstellen einer Hashtabelle zur Speicherung der Häufigkeiten
$dateiHaeufigkeiten = @{}

foreach ($datei in $alleDateien) {
    $dateiname = $datei.Name
    if ($dateiHaeufigkeiten.ContainsKey($dateiname)) {
        $dateiHaeufigkeiten[$dateiname]++
    } else {
        $dateiHaeufigkeiten[$dateiname] = 1
    }
}

# Erstellen einer Liste von PSCustomObjects
$dateiListe = foreach ($item in $dateiHaeufigkeiten.GetEnumerator()) {
    [PSCustomObject]@{
        Dateiname = $item.Key
        Anzahl = $item.Value
    }
}

# Sortieren der Liste nach Anzahl absteigend und Filtern, um nur Dateien mit einer Anzahl > 1 anzuzeigen
$dateiListe | Where-Object { $_.Anzahl -gt 2 } | Sort-Object Anzahl -Descending | Format-Table -AutoSize

if ($delte) {
    # Zusätzlicher Schritt: Löschen von Dateien, die öfter als zweimal vorkommen
    $dateiListe | Where-Object { $_.Anzahl -gt 2 } | ForEach-Object {
        $dateiname = $_.Dateiname

        # Finde alle Dateien mit diesem Namen und lösche sie
        Get-ChildItem -Path $Zielverzeichnis -Recurse -File -Filter $dateiname | ForEach-Object {
            Write-Host "Lösche Datei: $($_.FullName)"
            Remove-Item -Path $_.FullName -Force
        }
    }
}