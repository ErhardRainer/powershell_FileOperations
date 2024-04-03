# PowerShell-Skripte zur Dateiverwaltung
## bereinigeVerzeichnisse.ps1
### Kurzbeschreibung
Dieses PowerShell-Skript ist zur automatisierten Dateiverwaltung und -organisation konzipiert, wobei 7-Zip für Operationen auf Dateiebene verwendet wird. Es durchläuft alle Unterverzeichnisse eines angegebenen Startpfades, um basierend auf der Dateistruktur und dem Inhalt spezifische Aktionen durchzuführen.

### Voraussetzungen
* PowerShell
* 7-Zip muss installiert und der Pfad zur 7-Zip-Executable (7z.exe) muss korrekt angegeben werden.
### Technische Umsetzung
Das Skript akzeptiert zwei Parameter: StartPath, den Pfad des Startverzeichnisses, von dem aus die Verarbeitung beginnt, und demo, einen Schalter, der, wenn auf $true gesetzt, den Vorgang nur simuliert. Es definiert mehrere Funktionen, darunter DurchlaufeVerzeichnisse zum rekursiven Durchlaufen der Verzeichnisstruktur, BehandleRarDateien zur Behandlung von .rar-Dateien, einschließlich deren Entpackung mit 7-Zip, und BehandleUnterverzeichnisse zur speziellen Behandlung von Unter-Unterverzeichnissen basierend auf ihrer Struktur und Inhalt.
### Funktionen und Parameter
* DurchlaufeVerzeichnisse nimmt die Parameter Verzeichnis, demo, iteriereMehrereVerzeichnisse und zuIgnorierendeVerzeichnisse auf. Diese Funktion durchläuft alle Unterverzeichnisse und ruft je nach Situation spezifische Behandlungsfunktionen auf.
* BehandleRarDateien ist für die Behandlung von .rar-Dateien zuständig. Sie prüft, ob die .rar-Dateien eine vollständige Serie bilden und führt das Entpacken mit 7-Zip durch. Erforderliche Parameter sind Unterverzeichnis, PfadZu7Zip und demo.
* BehandleUnterverzeichnisse behandelt verschiedene Fälle basierend auf der Anzahl und Art der Unter-Unterverzeichnisse. Parameter sind Unterverzeichnis, demo, iteriereMehrereVerzeichnisse und zuIgnorierendeVerzeichnisse.
### Beispiele
Starten des Skripts im Demo-Modus für den Pfad "D:\Ordner":
PS> .\bereinigeVerzeichnisse.ps1 -StartPath "D:\Ordner" -demo $true
Dies simuliert die Verarbeitung, ohne tatsächliche Dateioperationen durchzuführen.
### Anmerkungen
* Autor: Erhard Rainer
* Version: 1.0
* Erstellungsdatum: 2024-01-09
Das Skript ermöglicht eine flexible Handhabung verschiedener Datei- und Verzeichnisstrukturen und nutzt dabei die Leistungsfähigkeit von 7-Zip für die Dateibehandlung.

## Create-SFVFile.ps1
### Kurzbeschreibung
Dieses PowerShell-Skript ist für die Erstellung einer SFV (Simple File Verification) Datei konzipiert. Es berechnet die CRC32-Checksummen aller Dateien in einem angegebenen Verzeichnis und speichert die Ergebnisse in einer SFV-Datei, die zur Überprüfung der Dateiintegrität genutzt werden kann.
### Voraussetzungen
* PowerShell
* Zugriff auf das zu überprüfende Verzeichnis und optional einen spezifizierten Pfad für die Speicherung der SFV-Datei.
### Technische Umsetzung
Das Skript nimmt zwei Parameter: directoryPath, den Pfad des zu überprüfenden Verzeichnisses, und optional sfvFilePath, den Pfad, unter dem die SFV-Datei gespeichert werden soll. Ist kein Pfad für die SFV-Datei angegeben, wird standardmäßig "checksums.sfv" im Quellverzeichnis erstellt. Eine CRC32-Klasse wird genutzt, um die Checksummen zu berechnen. Dateien, die größer als 2GB sind, werden übersprungen.
### Funktionen und Parameter
* Die Hauptfunktion Create-SFVFile führt den Prozess der Checksummenberechnung durch und speichert das Ergebnis in einer SFV-Datei. Die Parameter sind directoryPath und sfvFilePath.
### Beispiele
Erstellung einer SFV-Datei im Quellverzeichnis:
PS> .\Create-SFVFile.ps1 -directoryPath "C:\MeineDaten"
Erstellt eine SFV-Datei für "C:\MeineDaten" und speichert sie als "C:\MeineDaten\checksums.sfv".
Speicherung der SFV-Datei an einem benutzerdefinierten Ort:
PS> .\Create-SFVFile.ps1 -directoryPath "C:\MeineDaten" -sfvFilePath "D:\Backups\MeineDaten.sfv"
Erstellt eine SFV-Datei für "C:\MeineDaten" und speichert sie unter "D:\Backups\MeineDaten.sfv".
### Anmerkungen
Das Skript nutzt die CRC32-Checksummenberechnung, um die Integrität der Dateien zu überprüfen. Es ist besonders nützlich für die Überprüfung der Dateiintegrität nach dem Kopieren oder Verschieben von Dateien oder zur Verifizierung von Daten in Backup-Szenarien.
