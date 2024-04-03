<#
.SYNOPSIS
    PowerShell-Skript zur automatisierten Dateiverwaltung und -organisation unter Verwendung von 7-Zip.

.DESCRIPTION
    Dieses Skript durchläuft alle Unterverzeichnisse eines angegebenen Startpfades und führt basierend auf der Dateistruktur und dem Inhalt unterschiedliche Aktionen aus.

.PARAMETER StartPath
    Der Pfad des Startverzeichnisses, von dem aus die Verarbeitung beginnt.

.PARAMETER demo
    Wenn auf $true gesetzt, wird der Vorgang nur simuliert und keine realen Dateioperationen durchgeführt.

.EXAMPLE
    PS> .\bereinigeVerzeichnisse.ps1 -StartPath "D:\Ordner" -demo $true

.NOTES
    Autor: Erhard Rainer
    Version: 1.0
    Erstellungsdatum: 2024-01-09
#>

param(
    [string]$StartPath = "n:\_neu\",
    [bool]$demo = $false
)

# Funktion zum Durchlaufen der Unterverzeichnisse
function DurchlaufeVerzeichnisse {
    param (
        [string]$Verzeichnis,
        [bool]$demo,
        [bool]$iteriereMehrereVerzeichnisse,
        [array]$zuIgnorierendeVerzeichnisse
    )

    <#
    .SYNOPSIS
        Durchläuft rekursiv alle Unterverzeichnisse eines gegebenen Verzeichnisses.

    .DESCRIPTION
        Diese Funktion durchläuft alle Unterverzeichnisse des übergebenen Verzeichnisses und ruft abhängig vom Inhalt spezifische Behandlungsfunktionen auf.

    .PARAMETER Verzeichnis
        Das zu durchlaufende Verzeichnis.

    .EXAMPLE
        DurchlaufeVerzeichnisse -Verzeichnis "D:\Ordner"
    #>

    # Erhalte alle Unterverzeichnisse im aktuellen Verzeichnis
    $Unterverzeichnisse = Get-ChildItem -Path $Verzeichnis -Directory

    foreach ($Unterverzeichnis in $Unterverzeichnisse) {
        Write-Host "Bearbeite: $Unterverzeichnis" -BackgroundColor White -ForegroundColor Black

        # Pfad zur Info-Datei
        $infoDateiPfad = Join-Path -Path $Unterverzeichnis.FullName -ChildPath "info_folder.txt"

        # Überprüfe, ob die Info-Datei bereits existiert
        if (Test-Path -Path $infoDateiPfad) {
            # Füge eine Trennzeile hinzu
            "-----" | Out-File -FilePath $infoDateiPfad -Append
        }

        # Schreibe die Struktur des Unterverzeichnisses in die Info-Datei
        Get-ChildItem -Path $Unterverzeichnis.FullName -Recurse | ForEach-Object {
            $relativerPfad = $_.FullName -replace [regex]::Escape($Unterverzeichnis.FullName), ''
            "$relativerPfad" | Out-File -FilePath $infoDateiPfad -Append
        }

        # Überprüfe den Inhalt des Unterverzeichnisses
        $Dateien = Get-ChildItem -Path $Unterverzeichnis.FullName

        # Bestimme, ob .rar-Dateien im Unterverzeichnis vorhanden sind
        $RarDateienVorhanden = ($Dateien | Where-Object { $_.Extension -eq ".rar" }).Count -gt 0

        if ($RarDateienVorhanden) {
            # Fall 1: Behandlung von .rar-Dateien
            BehandleRarDateien -Unterverzeichnis $Unterverzeichnis.FullName -demo $demo -zuIgnorierendeVerzeichnisse $zuIgnorierendeVerzeichnisse
        }

        # Prüfe erneut nach .rar-Dateien und ob Unter-Unterverzeichnisse vorhanden sind
        $DateienNachEntpacken = Get-ChildItem -Path $Unterverzeichnis.FullName
        $RarDateienNachEntpacken = ($DateienNachEntpacken | Where-Object { $_.Extension -eq ".rar" }).Count -gt 0
        $UnterUnterverzeichnisseNachEntpacken = Get-ChildItem -Path $Unterverzeichnis.FullName -Directory

        if (-not $RarDateienNachEntpacken -and $UnterUnterverzeichnisseNachEntpacken.Count -gt 0) {
            # Fall 2: Behandlung von Unter-Unterverzeichnissen, wenn keine .rar-Dateien mehr vorhanden sind
            BehandleUnterverzeichnisse -Unterverzeichnis $Unterverzeichnis.FullName -demo $demo -iteriereMehrereVerzeichnisse $true -zuIgnorierendeVerzeichnisse $zuIgnorierendeVerzeichnisse
        }

        # Prüfe, ob Dateien oder Unterverzeichnisse vorhanden sind
        $DateienNachEntpacken = Get-ChildItem -Path $Unterverzeichnis.FullName
        $UnterUnterverzeichnisseNachEntpacken = Get-ChildItem -Path $Unterverzeichnis.FullName -Directory

        if ($DateienNachEntpacken.Count -eq 0 -and $UnterUnterverzeichnisseNachEntpacken.Count -eq 0) {
            Write-Host "Verzeichnis leer: $Unterverzeichnis" -ForegroundColor Red  -BackgroundColor White
        } elseif (-not $RarDateienNachEntpacken -and $UnterUnterverzeichnisseNachEntpacken.Count -eq 0) {
            Write-Host "Verzeichnis benötigt keine Bearbeitung: $Unterverzeichnis" -ForegroundColor Green
        }

    }
}

function Get-VerzeichnisGroesse {
    param (
        [string]$Pfad
    )

    # Prüfen, ob der Pfad existiert
    if (-not (Test-Path -Path $Pfad)) {
        Write-Host "Der Pfad '$Pfad' existiert nicht."
        return
    }

    try {
        # Ermitteln der Größe aller Dateien im Verzeichnis inklusive Unterverzeichnisse
        $gesamtGroesse = (Get-ChildItem -Path $Pfad -Recurse -File | Measure-Object -Property Length -Sum).Sum
        return $gesamtGroesse
    }
    catch {
        Write-Host "Ein Fehler ist aufgetreten: $_"
    }
}


# Funktion zur Behandlung von .rar-Dateien
function BehandleRarDateien {
    param (
        [string]$Unterverzeichnis,
        [string]$PfadZu7Zip = "C:\Program Files\7-Zip\7z.exe",
        [bool]$demo
    )

    <#
    .SYNOPSIS
        Behandelt Unterverzeichnisse, die ausschließlich .rar-Dateien enthalten.

    .DESCRIPTION
        Überprüft, ob die .rar-Dateien eine vollständige Serie bilden und führt das Entpacken mit 7-Zip durch. Bei Erfolg werden die Dateien gelöscht.

    .PARAMETER Unterverzeichnis
        Das zu überprüfende und zu bearbeitende Unterverzeichnis.

    .PARAMETER PfadZu7Zip
        Der vollständige Pfad zur 7-Zip-Executable.

    .EXAMPLE
        BehandleRarDateien -Unterverzeichnis "D:\Ordner\Subfolder" -PfadZu7Zip "C:\Program Files\7-Zip\7z.exe"
    #>

    # Erhalte alle .rar-Dateien im Unterverzeichnis
    $RarDateien = Get-ChildItem -Path $Unterverzeichnis -Filter *.rar

    # Ermittle die Sequenzlänge
    $sequenzLaenge = ErmittleSequenzLaenge -Dateien $RarDateien

    # Erzeuge den Namen der ersten Datei in der Serie basierend auf der Sequenzlänge
    $ersteDateiName = "part" + ("1".PadLeft($sequenzLaenge, '0')) + ".rar"

    # Überprüfe, ob mehrere Dateien mit dem Namen der ersten Datei existieren
    $ersteDateien = $RarDateien | Where-Object { $_.Name -eq $ersteDateiName }

    if ($ersteDateien.Count -gt 1) {
        Write-Host "Mehrere Archive der ersten Serie gefunden: $Unterverzeichnis" -ForegroundColor Red  -BackgroundColor White
        return 
    }

    # Überprüfe, ob die Dateien eine vollständige Serie bilden
    $Vollstaendig = ÜberprüfeVollständigkeit -RarDateien $RarDateien -sequenzLaenge $sequenzLaenge

    if ($Vollstaendig) {
        if (Test-Path -Path $PfadZu7Zip) {
            try {
                # Ermittle den Namen der ersten .rar-Datei im Verzeichnis
                $ersteDateiMuster = "*part" + ("1".PadLeft($sequenzLaenge, '0')) + ".rar"
                $ersteDatei = Get-ChildItem -Path $Unterverzeichnis -Filter $ersteDateiMuster | Select-Object -First 1

                if ($null -eq $ersteDatei) {
                    Write-Host "Erste .rar-Datei nicht gefunden im Verzeichnis: $Unterverzeichnis" -ForegroundColor Red -BackgroundColor White
                    return
                }
                # Berechne die Gesamtgröße aller .rar-Dateien im Verzeichnis
                $gesamtGröße = (Get-ChildItem -Path $Unterverzeichnis -Filter *.rar | Measure-Object -Property Length -Sum).Sum

                # Ermittle den freien Speicherplatz auf dem Laufwerk
                $laufwerk = Get-PSDrive -Name $Unterverzeichnis.Substring(0,1)
                $freierSpeicher = $laufwerk.Free

                if ($gesamtGröße -gt $freierSpeicher) {
                    Write-Host "Nicht genügend Speicherplatz verfügbar. Benötigt: $gesamtGröße, Verfügbar: $freierSpeicher" -ForegroundColor Red  -BackgroundColor White
                    return
                }
                $entpackBefehl = "& `"$PfadZu7Zip`" x `"$Unterverzeichnis\$ersteDatei`" -o`"$Unterverzeichnis`" -sdel"

                if ($demo) {
                    Write-Host "Demo-Modus: Würde ausführen: $entpackBefehl"
                } else {
                    # Invoke-Expression $entpackBefehl
                    $verzeichnisGroessebefore = Get-VerzeichnisGroesse -Pfad $Unterverzeichnis
                    Start-Process -FilePath "$PfadZu7Zip" -ArgumentList "x `"$Unterverzeichnis\$ersteDatei`" -o`"$Unterverzeichnis`" -sdel" -Wait
                    $verzeichnisGroesseafter = Get-VerzeichnisGroesse -Pfad $Unterverzeichnis
                    # Vergleiche die beiden Größen
                    if ($verzeichnisGroesseafter -gt 1.9 * $verzeichnisGroessebefore) {
                        # Überprüfe, ob .rar-Dateien vorhanden sind
                        if ($RarDateien.Count -gt 0) {
                            foreach ($RarDatei in $RarDateien) {
                                # Überprüfe, ob die Datei existiert
                                if (Test-Path -Path $RarDatei.FullName) {
                                    # Lösche die Datei, wenn sie existiert
                                    Remove-Item -Path $RarDatei.FullName -Force
                                    # Write-Host "Gelöscht: $($RarDatei.FullName)"
                                } else {
                                    Write-Host "Datei nicht gefunden: $($datei.FullName)"
                                }
                            }
                        } else {
                            Write-Host "Keine .rar-Dateien zum Löschen gefunden."
                        }
                        Write-Host "Entpacken erfolgreich: $Unterverzeichnis" -ForegroundColor Green
                    } else {
                        Write-Host "Verzeichnisgröße $Unterverzeichnis hat sich nicht mehr als verdoppelt. ($verzeichnisGroessebefore,$verzeichnisGroesseafter)"
                    }
                }
            } catch {
                Write-Host "Fehler beim Entpacken: $Unterverzeichnis" -ForegroundColor Red  -BackgroundColor White
            }
        } else {
            Write-Host "7-Zip-Executable nicht gefunden am Pfad: $PfadZu7Zip" -ForegroundColor Red -BackgroundColor White
        } 
    } else {
        Write-Host "Unvollständige RAR-Serie: $Unterverzeichnis" -ForegroundColor Red -BackgroundColor White
    }
}


function ErmittleSequenzLaenge {
    param (
        [System.IO.FileInfo[]]$Dateien
    )

    <#
    .SYNOPSIS
        Ermittelt die maximale Länge der Sequenznummern in den Dateinamen.

    .DESCRIPTION
        Diese Funktion durchläuft die gegebenen Dateien und ermittelt die maximale Länge der Zahlenfolge in den Dateinamen.

    .PARAMETER Dateien
        Die zu überprüfenden Dateien.

    .EXAMPLE
        $Dateien = Get-ChildItem -Path "D:\Ordner\Subfolder" -Filter *.rar
        $SequenzLaenge = ErmittleSequenzLaenge -Dateien $Dateien
    #>

    # Initialisiere die maximale Länge auf 0
    $maxLaenge = 0

    foreach ($datei in $Dateien) {
        if ($datei.Name -match 'part(\d+)\.rar$') {
            $laenge = $matches[1].Length
            if ($laenge -gt $maxLaenge) {
                $maxLaenge = $laenge
            }
        }
    }

    return $maxLaenge
}

function ÜberprüfeVollständigkeit {
    param (
        [System.IO.FileInfo[]]$RarDateien,
        [int]$sequenzLaenge
    )

    <#
    .SYNOPSIS
        Überprüft die Vollständigkeit einer Serie von .rar-Dateien.

    .DESCRIPTION
        Stellt fest, ob alle Teile einer .rar-Dateiserie vorhanden sind und ob keine Dateien fehlen. 
        Die letzte Datei in der Serie muss kleiner und alle anderen Dateien gleich groß sein.

    .PARAMETER RarDateien
        Ein Array von FileInfo-Objekten, die die .rar-Dateien im Unterverzeichnis repräsentieren.

    .PARAMETER sequenzLaenge
        Die Länge der Sequenznummern in den Dateinamen.

    .EXAMPLE
        $RarDateien = Get-ChildItem -Path "D:\Ordner\Subfolder" -Filter *.rar
        $SequenzLaenge = ErmittleSequenzLaenge -Dateien $RarDateien
        $Vollstaendig = ÜberprüfeVollständigkeit -RarDateien $RarDateien -sequenzLaenge $SequenzLaenge
    #>

    # Sortiere die Dateien basierend auf dem Dateinamen
    $sortierteDateien = $RarDateien | Sort-Object Name
    # Ermittle die Anzahl der Dateien
    $dateiAnzahl = $sortierteDateien.Count
    
    if ($demo) {
        Write-Host "Dateien gefunden: $dateiAnzahl"
        # Ausgabe der sortierten Dateien zur Überprüfung
        Write-Host "Sortierte Dateien:"
        foreach ($datei in $sortierteDateien) {
            Write-Host "   $($datei.Name)"
        }
    }

    # Überprüfe, ob es mindestens zwei Dateien gibt
    if ($dateiAnzahl -lt 2) {
        Write-Host "Nicht genügend Dateien vorhanden, mindestens zwei erwartet." -ForegroundColor Yellow
        return $false
    }

    # Überprüfe die Kontinuität der Dateireihe
    for ($i = 0; $i -lt $dateiAnzahl; $i++) {
        $dateiName = $sortierteDateien[$i].Name
        $erwarteteNummer = $i + 1
        $erwarteteNummerString = $erwarteteNummer.ToString("D$sequenzLaenge")
        $muster = "part$erwarteteNummerString.rar"

        if (-not $dateiName.EndsWith($muster)) {
            Write-Host "Fehlende Datei: $muster im Verzeichnis" -ForegroundColor Red -BackgroundColor White
            return $false
        }
    }

    # Ermittle die Größe der ersten Datei (erwartet, dass alle außer der letzten die gleiche Größe haben)
    $ersteDateigröße = ($sortierteDateien[0]).Length

    # Überprüfe die Größen aller Dateien außer der letzten
    for ($i = 0; $i -lt $dateiAnzahl - 1; $i++) {
        if ($sortierteDateien[$i].Length -ne $ersteDateigröße) {
            Write-Host "Größeninkonsistenz bei Datei: $($sortierteDateien[$i].Name). Erwartete Größe: $ersteDateigröße, Tatsächliche Größe: $($sortierteDateien[$i].Length)" -ForegroundColor Red -BackgroundColor White
            return $false
        }
    }

    # Überprüfe, ob die letzte Datei kleiner ist als die anderen
    $letzteDateigröße = ($sortierteDateien[-1]).Length
    if ($letzteDateigröße -ge $ersteDateigröße) {
        Write-Host "Die letzte Datei $($sortierteDateien[-1].Name) sollte kleiner sein als die vorherigen. Tatsächliche Größe: $letzteDateigröße" -ForegroundColor Red -BackgroundColor White
        return $false
    }

    return $true
}




# Funktion zur Behandlung von Unter-Unterverzeichnissen
function BehandleUnterverzeichnisse {
    param (
        [string]$Unterverzeichnis,
        [bool]$demo = $false,
        [bool]$iteriereMehrereVerzeichnisse = $false,
        [array]$zuIgnorierendeVerzeichnisse
    )

    <#
    .SYNOPSIS
        Behandelt Unterverzeichnisse basierend auf der Anzahl und Art der Unter-Unterverzeichnisse.

    .DESCRIPTION
        Unterscheidet zwischen verschiedenen Fällen basierend auf der Struktur und dem Inhalt der Unter-Unterverzeichnisse.

    .PARAMETER Unterverzeichnis
        Das zu überprüfende und zu bearbeitende Unterverzeichnis.

    .PARAMETER demo
        Wenn auf $true gesetzt, wird der Vorgang nur simuliert und keine realen Dateioperationen durchgeführt.

    .EXAMPLE
        BehandleUnterverzeichnisse -Unterverzeichnis "D:\Ordner\Subfolder" -demo $true
    #>

    # Erhalte alle Unter-Unterverzeichnisse und Dateien im aktuellen Unterverzeichnis
    $UnterUnterverzeichnisse = Get-ChildItem -Path $Unterverzeichnis -Directory
    $Dateien = Get-ChildItem -Path $Unterverzeichnis -File


    # Anpassung für das Iterieren über mehrere Verzeichnisse
    $UnterUnterverzeichnisseCount = $UnterUnterverzeichnisse.Count
    if ($UnterUnterverzeichnisseCount -gt 1 -and $iteriereMehrereVerzeichnisse) {
        $UnterUnterverzeichnisseCount = 1
    }

    # Fallunterscheidung basierend auf der Anzahl der Unter-Unterverzeichnisse
    switch ($UnterUnterverzeichnisseCount) {
        0 {
            # Fall 2c: Keine Unter-Unterverzeichnisse, aber andere Dateien
            if ($Dateien.Count -gt 0) {
                Write-Host "Dateien ohne Unter-Unterverzeichnisse gefunden: $Unterverzeichnis" -ForegroundColor Magenta -BackgroundColor White
            }
        }
        1 {
            # Fall 2a: Genau ein Unter-Unterverzeichnis
            # Finde Unterverzeichnisse, die Dateien enthalten
            if ($iteriereMehrereVerzeichnisse -eq $true) {
                $gefundeneVerzeichnisse = @(FindeUnterverzeichnisse -aktuellesVerzeichnis $Unterverzeichnis -flat $true -zuIgnorierendeVerzeichnisse $zuIgnorierendeVerzeichnisse)
            } else {
                $gefundeneVerzeichnisse = @(FindeUnterverzeichnisse -aktuellesVerzeichnis $Unterverzeichnis -flat $false -zuIgnorierendeVerzeichnisse $zuIgnorierendeVerzeichnisse)
            }
            if ($gefundeneVerzeichnisse.Count -eq 1) {
                # Genau ein Unter-Unterverzeichnis gefunden
                $gefundeneVerzeichnisse | fl
                foreach ($ZielUnterverzeichnis in $gefundeneVerzeichnisse) {
                    Write-Host "Verschiebe Dateien: $VerschiebeErgebnis"
                    $VerschiebeErgebnis = VerschiebeDateien -QuellVerzeichnis $ZielUnterverzeichnis -ZielVerzeichnis $Unterverzeichnis -demo $demo
                    if (-not $demo -and ($VerschiebeErgebnis -eq $true)) {
                        # Trenne den Pfad in einzelne Teile
                        if ($ZielUnterverzeichnis -ne $Unterverzeichnis) {
                            $pfadTeile = ($ZielUnterverzeichnis -replace [regex]::Escape($Unterverzeichnis), '').TrimStart('\') -split '\\'
                            if ($demo) {
                                Write-Host "ZielUnterverzeichnis: $ZielUnterverzeichnis"
                                Write-Host "Unterverzeichnis: $Unterverzeichnis"
                                Write-Host "pfadTeile.Count: $($pfadTeile.Count)"
                                foreach ($pfadTeil in $pfadteile) {
                                    Write-Host "pfadTeil: $pfadTeil"
                                }
                            }
                            $ersteEbeneUnterverzeichnis = Join-Path -Path $Unterverzeichnis -ChildPath $pfadTeile[0]
                            # Überprüfe, ob das Verzeichnis existiert
                            if (Test-Path -Path $ersteEbeneUnterverzeichnis) {
                                Write-Host "Lösche: $ersteEbeneUnterverzeichnis" -ForegroundColor Magenta -BackgroundColor White
                                # Prüfe, ob das Verzeichnis leer ist, bevor es gelöscht wird
                                $Inhalt = Get-ChildItem -Path $ersteEbeneUnterverzeichnis -Recurse -File
                                if ($Inhalt.Count -eq 0) {
                                    # Das Verzeichnis ist leer
                                     if (-not $demo) {
                                         Remove-Item -Path $ersteEbeneUnterverzeichnis -Recurse -Force
                                      } else {
                                          Write-Host "Demo-Modus: Würde löschen: $ersteEbeneUnterverzeichnis"
                                      }
                                    } else {
                                        Write-Host "Verzeichnis ist nicht leer: $ersteEbeneUnterverzeichnis" -ForegroundColor Red -BackgroundColor White
                                    }
                            }
                            Write-Host "Verarbeitung abgeschlossen: $Unterverzeichnis" -ForegroundColor Green
                        } else {
                            Write-Host "Fehler: $Unterverzeichnis = $ZielUnterverzeichnis" -ForegroundColor Red -BackgroundColor White
                        }
                    } elseif ($VerschiebeErgebnis -eq $true) {
                        Write-Host "Fehler beim Verschieben der Dateien von $ZielUnterverzeichnis" -ForegroundColor Red -BackgroundColor White
                    }
                }
            } elseif ($gefundeneVerzeichnisse.Count -gt 1) {
                # Mehrere Unter-Unterverzeichnisse gefunden
                Write-Host "Mehrere Unter-Unterverzeichnisse mit Dateien gefunden: $Unterverzeichnis" -ForegroundColor Red -BackgroundColor White
                Write-Host "gefundene Verzeichnisse:"
                foreach ($verzeichnis in $gefundeneVerzeichnisse) {
                    Write-Host "   $($verzeichnis)"
                }
                Write-Host "------------------------------------------"
            } else {
                # Keine Dateien in den Unter-Unterverzeichnissen gefunden
                Write-Host "Keine Dateien in Unter-Unterverzeichnissen gefunden: $Unterverzeichnis" -ForegroundColor Red -BackgroundColor White
            }
        }
        default {
            # Fall 2b: Mehrere Unter-Unterverzeichnisse
            $ignorierteVerzeichnisse = $UnterUnterverzeichnisse.Name | Where-Object { $zuIgnorierendeVerzeichnisse -ccontains $_ }

            if ($ignorierteVerzeichnisse.Count -eq $UnterUnterverzeichnisseCount) {
                Write-Host "Alle Unter-Unterverzeichnisse werden ignoriert. Alles OK: $Unterverzeichnis" -ForegroundColor Green
            } else {
                Write-Host "Mehrere Unter-Unterverzeichnisse gefunden: $Unterverzeichnis" -ForegroundColor Red -BackgroundColor White
            }
        }
    }
}

function FindeUnterverzeichnisse {
    param (
        [string]$aktuellesVerzeichnis,
        [int]$ebene = 0,
        [bool]$flat = $false,
        [array]$zuIgnorierendeVerzeichnisse
    )

    # Definiere ein Array von zu ignorierenden Unterordnernamen


    $gefundeneVerzeichnisse = @()
    $unterVerzeichnisse = Get-ChildItem -Path $aktuellesVerzeichnis -Directory

    # Überprüfe, ob Dateien im aktuellen Verzeichnis vorhanden sind
    $dateienImVerzeichnis = Get-ChildItem -Path $aktuellesVerzeichnis -File

    if ($ebene -gt 0 -and $dateienImVerzeichnis.Count -gt 0) {
        # Ebene > 0 und Dateien vorhanden: Füge das aktuelle Verzeichnis hinzu
        $gefundeneVerzeichnisse += $aktuellesVerzeichnis

        # Wenn $flat = $true, suche weiter in Unter-Unterverzeichnissen
        if (-not $flat) {
            return $gefundeneVerzeichnisse
        }
    }

    # Suche in Unter-Unterverzeichnissen, ignoriere Verzeichnisse aus der Ignorierliste
    foreach ($unterVerz in $unterVerzeichnisse) {
        if ($zuIgnorierendeVerzeichnisse -ccontains $unterVerz.Name) {
            # Überspringe die Suche in diesem Verzeichnis
            continue
        }

        # Rekursive Suche in den Unter-Unterverzeichnissen
        $gefundeneInUnterVerz = (FindeUnterverzeichnisse -aktuellesVerzeichnis $unterVerz.FullName -ebene ($ebene + 1) -flat $flat -zuIgnorierendeVerzeichnisse $zuIgnorierendeVerzeichnisse)
        if ($gefundeneInUnterVerz -ne $null) {
            $gefundeneVerzeichnisse += $gefundeneInUnterVerz
        }
    }

    return $gefundeneVerzeichnisse
}



function VerschiebeDateien {
    param (
        [string]$QuellVerzeichnis,
        [string]$ZielVerzeichnis,
        [bool]$demo = $false
    )

    <#
    .SYNOPSIS
        Verschiebt alle Dateien von einem Verzeichnis in ein anderes.

    .DESCRIPTION
        Diese Funktion verschiebt alle Dateien aus dem angegebenen Quellverzeichnis in das Zielverzeichnis.
        Im Demo-Modus werden die Aktionen nur simuliert.

    .PARAMETER QuellVerzeichnis
        Das Verzeichnis, aus dem die Dateien verschoben werden.

    .PARAMETER ZielVerzeichnis
        Das Verzeichnis, in das die Dateien verschoben werden.

    .PARAMETER demo
        Wenn auf $true gesetzt, werden die Aktionen nur simuliert.

    .EXAMPLE
        VerschiebeDateien -QuellVerzeichnis "D:\Ordner\Subfolder1" -ZielVerzeichnis "D:\Ordner\Subfolder2" -demo $true
    #>

    try {
        if ($demo) {
            Write-Host "$QuellVerzeichnis ==> $ZielVerzeichnis" -ForegroundColor Yellow
            Get-ChildItem -Path $QuellVerzeichnis -Recurse | ForEach-Object { Write-Host "   $($_.FullName) -> $ZielVerzeichnis" -ForegroundColor Yellow }
        } else {
            Write-Host "$QuellVerzeichnis ==> $ZielVerzeichnis" -ForegroundColor Green
            $Objekte = Get-ChildItem -Path $QuellVerzeichnis -Recurse

            foreach ($objekt in $Objekte) {
                $vollstaendigerPfad = $objekt.FullName

                # Überspringe das Quellverzeichnis selbst
                if ($vollstaendigerPfad -eq $QuellVerzeichnis) {
                    continue
                }

                if ($vollstaendigerPfad.Length -le 255) {
                    Write-Host "Verschiebe: $vollstaendigerPfad ==> $ZielVerzeichnis"
                    # Überprüfen, ob die Datei existiert
                    if (Test-Path -Path $vollstaendigerPfad) {
                        Move-Item -Path $vollstaendigerPfad -Destination $ZielVerzeichnis
                    } else {
                        Write-Host "Datei existiert nicht: $vollstaendigerPfad"
                    }
                } else {
                    Write-Host "Pfad zu lang: $vollstaendigerPfad" -ForegroundColor Red -BackgroundColor White
                    return $false
                }
            }
        }
        return $true
    } catch {
        Write-Host "Ein Fehler ist aufgetreten: $_" -ForegroundColor Red -BackgroundColor White
        return $false
    }
}

# Skript-Start
cls
$iteriereMehrereVerzeichnisse = $true
$zuIgnorierendeVerzeichnisse = @('Sample', 'Subs', 'Proof', 'sample', 'subs', 'proof', 'SUBS', 'SAMPLE', 'PROOF')
# Prüfe, ob das Startverzeichnis existiert
if (Test-Path -Path $StartPath) {
    if ($demo)
    {
        Write-Host "DEMO MODUS" -BackgroundColor Yellow -ForegroundColor Black
    }
    # Aufruf von DurchlaufeVerzeichnisse, wenn das Verzeichnis existiert
    DurchlaufeVerzeichnisse -Verzeichnis $StartPath -demo $demo -iteriereMehrereVerzeichnisse $iteriereMehrereVerzeichnisse -zuIgnorierendeVerzeichnisse $zuIgnorierendeVerzeichnisse
} else {
    # Fehlermeldung, wenn das Startverzeichnis nicht existiert
    Write-Host "Das Verzeichnis '$StartPath' existiert nicht." -ForegroundColor Red -BackgroundColor White
}