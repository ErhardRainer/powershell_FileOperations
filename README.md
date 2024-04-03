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
> .\bereinigeVerzeichnisse.ps1 -StartPath "D:\Ordner" -demo $true
Dies simuliert die Verarbeitung, ohne tatsächliche Dateioperationen durchzuführen.
### Anmerkungen
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
> .\Create-SFVFile.ps1 -directoryPath "C:\MeineDaten"
Erstellt eine SFV-Datei für "C:\MeineDaten" und speichert sie als "C:\MeineDaten\checksums.sfv".
Speicherung der SFV-Datei an einem benutzerdefinierten Ort:
> .\Create-SFVFile.ps1 -directoryPath "C:\MeineDaten" -sfvFilePath "D:\Backups\MeineDaten.sfv"
Erstellt eine SFV-Datei für "C:\MeineDaten" und speichert sie unter "D:\Backups\MeineDaten.sfv".
### Anmerkungen
Das Skript nutzt die CRC32-Checksummenberechnung, um die Integrität der Dateien zu überprüfen. Es ist besonders nützlich für die Überprüfung der Dateiintegrität nach dem Kopieren oder Verschieben von Dateien oder zur Verifizierung von Daten in Backup-Szenarien.

## BackupAndManageVersions.ps1
### Kurzbeschreibung
Dieses PowerShell-Skript dient dem automatischen Backup und der Verwaltung von Verzeichnisversionen. Es erstellt gepackte Backups von allen Unterverzeichnissen eines angegebenen Quellpfades, wenn Änderungen festgestellt werden, und speichert diese im Zielverzeichnis. Dabei wird eine definierte Anzahl der neuesten Backup-Versionen behalten und ältere Versionen werden gelöscht.
### Voraussetzungen
* PowerShell
* Genügend Speicherplatz im Zielverzeichnis für die Backup-Dateien.
* Zugriffsrechte für das Lesen der Quellverzeichnisse und das Schreiben in das Zielverzeichnis.
### Technische Umsetzung
Das Skript nimmt drei Parameter: sourcePath (Pfad zum Quellverzeichnis), destinationPath (Pfad zum Zielverzeichnis, wo die Backups gespeichert werden) und keepVersions (Anzahl der Backup-Versionen, die erhalten bleiben sollen). Es enthält die Funktion Pack-Directory, die ein Verzeichnis in eine ZIP-Datei komprimiert und im Zielverzeichnis speichert.
### Funktionen und Parameter
* Pack-Directory: Nimmt den Pfad des zu packenden Verzeichnisses (directoryToPack) und den Pfad der Ziel-ZIP-Datei (destinationZipPath) auf. Erstellt das Zielverzeichnis, falls es nicht existiert, und packt das Verzeichnis in eine ZIP-Datei.
### Beispiele
Backup aller Unterverzeichnisse von W:\ und Speicherung in G:\Meine Ablage_Programmierung, wobei die letzten 5 Versionen jedes Backups behalten werden:

PS> .\BackupAndManageVersions.ps1 -sourcePath "W:\" -destinationPath "G:\Meine Ablage\_Programmierung" -keepVersions 5
### Anmerkungen
Das Skript prüft das Datum der letzten Änderung in jedem Unterverzeichnis und erstellt nur dann ein neues Backup, wenn Änderungen seit dem letzten Backup festgestellt wurden.
Durch die Begrenzung der Anzahl der Backup-Versionen hilft das Skript, den Speicherplatz effizient zu nutzen.
Die Verwaltung und Automatisierung des Backup-Prozesses kann durch Einplanen des Skripts über den Windows Task Scheduler weiter automatisiert werden.

## Rename_Folder.ps1
### Kurzbeschreibung
Dieses PowerShell-Skript ist dafür konzipiert, Verzeichnisse, die .rar Dateien enthalten, umzubenennen, indem es "[uv]" zum Verzeichnisnamen hinzufügt. Es durchsucht rekursiv ein angegebenes Startverzeichnis nach solchen Unterverzeichnissen und führt die Umbenennung durch.
### Voraussetzungen
* PowerShell
### Technische Umsetzung
* Das Skript benötigt einen Pflichtparameter:
** **StartDirectory:** Definiert das Startverzeichnis, von dem aus die Suche und Umbenennung beginnen soll.
Es durchläuft rekursiv alle Unterverzeichnisse des angegebenen Startverzeichnisses, sucht nach .rar Dateien und benennt die entsprechenden Verzeichnisse um, indem "[uv]" an den Namen angehängt wird. Es wird eine Meldung auf der Konsole ausgegeben, die über den Umbenennungsprozess informiert.
### Beispiele
Starten des Skripts für das Verzeichnis "J:":
> .\Rename_Folder.ps1 -StartDirectory "J:"
### Anmerkungen
Das Skript bietet eine einfache Möglichkeit, Verzeichnisse basierend auf dem Vorhandensein von .rar Dateien umzubenennen und kann für verschiedene Anwendungsfälle im Dateimanagement angepasst werden.

## UnterOrdner_verschieben.ps1
### Kurzbeschreibung
Dieses PowerShell-Skript verschiebt Verzeichnisse basierend auf einem optionalen Regex-Muster, das vierstellige Jahreszahlen am Anfang des Verzeichnisnamens identifiziert, von einem Quell- zu einem Zielverzeichnis. Es berechnet die Gesamtgröße der zu verschiebenden Verzeichnisse und gibt während des Verschiebeprozesses Informationen über den Fortschritt aus.
### Voraussetzungen
- PowerShell
### Technische Umsetzung
Das Skript akzeptiert drei Parameter:
- **QuellVerzeichnis**: Das Verzeichnis, von dem aus die Dateien verschoben werden sollen.
- **ZielVerzeichnis**: Das Zielverzeichnis, in das die Dateien verschoben werden sollen.
- **regexPattern**: Ein optionales Regex-Muster, das verwendet wird, um zu bestimmen, welche Verzeichnisse verschoben werden sollen. Standardmäßig sucht es nach einer vierstelligen Jahreszahl am Anfang des Namens.

Das Skript filtert Verzeichnisse im Quellverzeichnis, die dem optionalen Regex-Muster entsprechen, ermittelt deren Gesamtgröße und verschiebt sie einzeln ins Zielverzeichnis. Während des Verschiebungsprozesses gibt es den Fortschritt, die übertragene Datenmenge, die Dauer, die aktuelle Transferrate und die geschätzte verbleibende Zeit aus.
### Beispiele
Starten des Skripts mit einem angegebenen Quell- und Zielverzeichnis und einem Regex-Muster:
> .\UnterOrdner_verschieben.ps1 -QuellVerzeichnis "y:\_Filme\" -ZielVerzeichnis "n:\" -regexPattern "^\d{4} -"
### Anmerkungen
Das Skript optimiert den Prozess des Verschiebens von Verzeichnissen basierend auf spezifischen Kriterien, was besonders nützlich für die Organisation von Dateien und Verzeichnissen nach bestimmten Mustern oder Konventionen ist.
