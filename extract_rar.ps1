# Definieren eines Arrays von Startverzeichnissen
$startdirs = @(
    "j:\Love Me\Love.Me.S01.German.DL.1080p.WEB.x264-WvF - serienfans.org\",
    "j:\Love Me\Love.Me.S02.GERMAN.DL.1080P.WEB.H264-WAYNE - filecrypt.cc\"
)
$PfadZu7Zip = "C:\Program Files\7-Zip\7z.exe"
$password = "serienfans.org" #"w00t" #"serienfans.org" #"serienjunkies.org"

# Funktion, um die Größe eines Verzeichnisses zu ermitteln
function Get-DirectorySize {
    param (
        [string]$Path
    )

    (Get-ChildItem -Path $Path -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1GB  # Größe in Gigabyte
}

foreach ($startdir in $startdirs) {
    # Finde alle .part1.rar und .part01.rar Dateien im aktuellen Verzeichnis
    $filesToExtract = Get-ChildItem -Path $startdir -Recurse -Filter "*.part*.rar" |
                      Where-Object { $_.Name -match "part1\.rar$|part01\.rar$" }

    # Überprüfen, ob $filesToExtract leer ist
    if (-not $filesToExtract) {
        # Suche nach einfachen .rar Dateien
        $filesToExtract = Get-ChildItem -Path $startdir -Recurse -Filter "*.rar" |
                          Where-Object { $_.Name -match "\.rar$" -and $_.Name -notmatch "part\d+\.rar$" }
    }

    foreach ($file in $filesToExtract) {
        $directory = $file.DirectoryName
        Write-Host "Verzeichnis: $directory" -BackgroundColor Red
        $baseName = $file.BaseName -replace "part1$|part01$", "part*"

        # Finde alle entsprechenden .part*.rar Dateien basierend auf dem Basisteil des Namens
        $partFiles = Get-ChildItem -Path $directory -Filter "$baseName.rar"
        $partFilesSize = (($partFiles | Measure-Object -Property Length -Sum).Sum / 1GB)

        # Größe des Verzeichnisses vor dem Entpacken
        $initialSize = Get-DirectorySize -Path $directory

        # Entpacken der Datei
        Write-Host "Entpacke $($file.FullName)"
        $arguments = "x", "`"$($file.FullName)`"", "-o`"$directory`"", "-aoa"

        # Prüfen, ob das Passwort gesetzt ist
        if (-not [string]::IsNullOrWhiteSpace($password)) {
            $arguments += "-p$password"
        }

        Start-Process -FilePath $PfadZu7Zip -ArgumentList $arguments -Wait

        # Größe des Verzeichnisses nach dem Entpacken
        $finalSize = Get-DirectorySize -Path $directory

        # Überprüfen, ob der Ordner um mindestens die Größe der .part*.rar Dateien gewachsen ist
        Write-Host "FileSize initial: $initialSize"
        Write-Host "FileSize part.rar: $partFilesSize"
        Write-Host "FileSize final: $finalSize"
        if ($finalSize -gt ($initialSize + $partFilesSize)) {
            # Lösche alle .part*.rar Dateien im Verzeichnis
            Write-Host "Lösche: $partFiles"
            # $partFiles | Remove-Item -Force
        } else {
            Write-Host "Verzeichnisgröße $directory nicht entsprechend gewachsen $initialSize + $partFilesSize < $finalSize GB"
        }
    }
}