<#
.SYNOPSIS
Erstellt eine SFV (Simple File Verification) Datei für ein angegebenes Verzeichnis.

.DESCRIPTION
Dieses Skript durchläuft alle Dateien in einem spezifizierten Verzeichnis und berechnet deren CRC32-Checksummen. 
Die Ergebnisse werden in einer SFV-Datei gespeichert, die zur späteren Überprüfung der Dateiintegrität verwendet werden kann.
Ist kein Pfad für die SFV-Datei angegeben, wird eine Standard-SFV-Datei namens "checksums.sfv" im Quellverzeichnis erstellt.

.PARAMETER directoryPath
Der Pfad zum Verzeichnis, für das die SFV-Datei erstellt werden soll. Dieser Parameter ist erforderlich.

.PARAMETER sfvFilePath
Der optionale Pfad, unter dem die SFV-Datei gespeichert werden soll. Wird dieser Parameter nicht angegeben, 
wird die SFV-Datei als "checksums.sfv" im Quellverzeichnis gespeichert.

.EXAMPLE
PS> .\Create-SFVFile.ps1 -directoryPath "C:\MeineDaten"

Erstellt eine SFV-Datei für alle Dateien in "C:\MeineDaten" und speichert die SFV-Datei als "C:\MeineDaten\checksums.sfv".

.EXAMPLE
PS> .\Create-SFVFile.ps1 -directoryPath "C:\MeineDaten" -sfvFilePath "D:\Backups\MeineDaten.sfv"

Erstellt eine SFV-Datei für alle Dateien in "C:\MeineDaten" und speichert die SFV-Datei unter "D:\Backups\MeineDaten.sfv".

.NOTES
Das Skript verwendet die CRC32-Checksummenberechnung, um die Integrität der Dateien im angegebenen Verzeichnis zu überprüfen.
#>


param(
    [Parameter(Mandatory=$true)]
    [string]$directoryPath,
    
    [Parameter(Mandatory=$false)]
    [string]$sfvFilePath
)

Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;

public class CRC32 {
    private uint[] table;

    public uint ComputeChecksum(byte[] bytes) {
        uint crc = 0xffffffff;
        for (int i = 0; i < bytes.Length; i++) {
            byte index = (byte)(((crc) & 0xff) ^ bytes[i]);
            crc = (crc >> 8) ^ table[index];
        }
        return ~crc;
    }

    public CRC32() {
        uint poly = 0xedb88320;
        table = new uint[256];
        for (uint i = 0; i < 256; i++) {
            uint temp = i;
            for (int j = 8; j > 0; j--) {
                if ((temp & 1) == 1) {
                    temp = (temp >> 1) ^ poly;
                } else {
                    temp >>= 1;
                }
            }
            table[i] = temp;
        }
    }
}
"@

function Create-SFVFile {
    param(
        [string]$directoryPath,
        [string]$sfvFilePath
    )

    # Setzt den Standardnamen für die SFV-Datei, falls kein sfvFilePath angegeben wurde
    if (-not $sfvFilePath) {
        $sfvFilePath = Join-Path -Path $directoryPath -ChildPath "checksums.sfv"
    }

    $crc32 = New-Object CRC32
    $sfvContent = @()

    Get-ChildItem -Path $directoryPath -File | Where-Object { $_.FullName -ne $sfvFilePath } | ForEach-Object {
        if ($_.Length -gt 2GB) {
            Write-Host "Überspringe $($_.FullName), da die Datei größer als 2GB ist."
        } else {
            $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
            $checksum = $crc32.ComputeChecksum($bytes)
            $sfvContent += "$($_.Name) $(("{0:X8}" -f $checksum).ToLower())"
        }
    }

    $sfvContent | Out-File -FilePath $sfvFilePath
    Write-Host "SFV file created at: $sfvFilePath"
}

Create-SFVFile -directoryPath $directoryPath -sfvFilePath $sfvFilePath