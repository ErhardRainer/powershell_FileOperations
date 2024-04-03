# Definiere das Ausgangsverzeichnis
$startdir = "n:\" # Pfad anpassen

# Durchlaufe alle Verzeichnisse im Startverzeichnis
Get-ChildItem -Path $startdir -Directory | ForEach-Object {
    $currentDir = $_
    $dirName = $currentDir.Name

    # Prüfe, ob der Ordnername mit einer vierstelligen Zahl beginnt
    if ($dirName -match '^\d{4}') {
        $year = $Matches[0]

        # Zielverzeichnis basierend auf dem Muster "+ [Jahr]" erstellen
        $targetDirName = "+ " + $year
        $targetDir = Join-Path $startdir $targetDirName

        # Erstelle das Zielverzeichnis, falls es nicht existiert
        if (-not (Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory
        }

        # Verschiebe das Verzeichnis in das entsprechende Jahresverzeichnis
        $newLocation = Join-Path $targetDir $dirName
        Move-Item -Path $currentDir.FullName -Destination $newLocation
    }
}