param (
    [string]$startPath = "i:\00_Pee_Sonstiges\",
    [int]$filesCount = 150
)

function Sanitize-FileName($fileName) {
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    return $fileName -replace $re, ''
}

# Prüfen, ob der Startpfad existiert
if (-not (Test-Path -Path $startPath)) {
    Write-Error "Der angegebene Pfad existiert nicht."
    return
}

# Dateien im Startpfad holen und nach Erstellungsdatum sortieren
Write-Host "Scanne das Verzeichnis: $startPath"
$allFiles = Get-ChildItem -Path $startPath -File | Sort-Object CreationTime

# Liste der tatsächlich vorhandenen Dateien erstellen
$existingFiles = @()
foreach ($file in $allFiles) {
    if (Test-Path -Path $file.FullName) {
        $existingFiles += $file
    } else {
        Write-Warning "Datei $($file.FullName) wurde nicht gefunden und wird übersprungen."
    }
}

# Unterordner erstellen und Dateien verschieben
$folderIndex = 1
while ($existingFiles.Count -gt 0) {
    $folderName = "{0:D4}" -f $folderIndex
    $folderPath = Join-Path -Path $startPath -ChildPath $folderName
    
    if (Test-Path -Path $folderPath) {
        $existingFilesInFolder = (Get-ChildItem -Path $folderPath -File).Count
        $filesToMove = $filesCount - $existingFilesInFolder
        if ($filesToMove -le 0) {
            Write-Host "Verzeichnis $folderPath ist bereits voll."
            $folderIndex++
            continue
        }
    } else {
        New-Item -Path $folderPath -ItemType Directory
        $filesToMove = $filesCount
    }

    Write-Host "Befülle Verzeichnis $folderPath"
    $filesToProcess = $existingFiles[0..($filesToMove - 1)]
    foreach ($file in $filesToProcess) {
        $sanitizedFileName = Sanitize-FileName $file.Name
        $destinationPath = Join-Path -Path $folderPath -ChildPath $sanitizedFileName
        
        if (-not (Test-Path -Path $destinationPath)) {
            Move-Item -Path $file.FullName -Destination $destinationPath
        } else {
            Write-Warning "Eine Datei mit dem Namen $sanitizedFileName existiert bereits im Zielverzeichnis und wurde übersprungen."
        }
    }

    $existingFiles = $existingFiles[$filesToMove..$existingFiles.Count]
    $folderIndex++
}