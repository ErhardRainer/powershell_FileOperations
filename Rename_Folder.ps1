# Startverzeichnis definieren
$startdir = "J:\" # Ändere dies zu deinem Startverzeichnis

# Rekursives Durchlaufen aller Unterverzeichnisse
Get-ChildItem -Path $startdir -Directory | ForEach-Object {
    $directory = $_
    $rarFiles = Get-ChildItem -Path $directory.FullName -Filter "*.rar" -Recurse

    # Überprüfen, ob .rar Dateien vorhanden sind
    if ($rarFiles.Count -gt 0) {
        $newDirectoryName = $directory.FullName + " [uv]"

        # Umbenennen des Verzeichnisses
        $sourceName = $directory.FullName
        Write-Host "Benenne Verzeichnis $sourceName in $newDirectoryName um."
        # Rename-Item -Path $directory.FullName -NewName $newDirectoryName
        # Write-Host "Verzeichnis umbenannt: $newDirectoryName"
    }
}

Write-Host "Verarbeitung abgeschlossen."
