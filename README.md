# PowerShell-Skripte zur Dateiverwaltung
## [ComprehensiveFileManagementWith7Zip.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/ComprehensiveFileManagementWith7Zip.ps1)
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

## [Create-SFVFile.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/Create-SFVFile.ps1)
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

## [BackupAndManageVersions.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/BackupAndManageVersions.ps1)
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
> .\BackupAndManageVersions.ps1 -sourcePath "W:\" -destinationPath "G:\Meine Ablage\_Programmierung" -keepVersions 5
### Anmerkungen
Das Skript prüft das Datum der letzten Änderung in jedem Unterverzeichnis und erstellt nur dann ein neues Backup, wenn Änderungen seit dem letzten Backup festgestellt wurden.
Durch die Begrenzung der Anzahl der Backup-Versionen hilft das Skript, den Speicherplatz effizient zu nutzen.
Die Verwaltung und Automatisierung des Backup-Prozesses kann durch Einplanen des Skripts über den Windows Task Scheduler weiter automatisiert werden.

## [RenameFolderIfRarFiles.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/RenameFolderIfRarFiles.ps1)
### Kurzbeschreibung
Dieses PowerShell-Skript durchsucht ein Startverzeichnis rekursiv nach Unterverzeichnissen, die .rar Dateien enthalten, und benennt diese Verzeichnisse um, indem es "[uv]" an den Verzeichnisnamen anhängt. Es dient der Kennzeichnung von Verzeichnissen, die spezifische Inhalte enthalten, um diese leichter identifizieren zu können.
### Voraussetzungen
- PowerShell
- Zugriff auf das Startverzeichnis
### Technische Umsetzung
Das Skript akzeptiert einen verpflichtenden Parameter:
- **StartDirectory**: Definiert das Startverzeichnis, von dem aus die Suche und Umbenennung der Verzeichnisse beginnen soll.

Es verwendet `Get-ChildItem` zur rekursiven Suche nach .rar Dateien in allen Unterverzeichnissen des Startverzeichnisses. Wenn in einem Verzeichnis .rar Dateien gefunden werden, wird der Verzeichnisname geändert, indem "[uv]" angehängt wird.

### Funktionen und Parameter
- **Get-ChildItem**: Wird verwendet, um rekursiv nach .rar Dateien in den Unterverzeichnissen des Startverzeichnisses zu suchen.
- **Rename-Item**: Benennt die Verzeichnisse um, die .rar Dateien enthalten.
### Beispiele
Um alle Verzeichnisse, die .rar Dateien enthalten, im Startverzeichnis `"J:\"` umzubenennen:
> .\RenameFolderIfRarFiles.ps1 -StartDirectory "J:\"
### Versionshistorie
- 2024-04-03 - 1.0 - Erste Version

Dieses Skript ist eine effektive Lösung zur automatischen Kennzeichnung von Verzeichnissen, die bestimmte Dateitypen enthalten, und verbessert so die Übersichtlichkeit und Organisiertheit des Dateisystems.
## [MoveFoldersByRegex.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/MoveFoldersByRegex.ps1)
### Kurzbeschreibung
Dieses PowerShell-Skript dient dazu, Verzeichnisse von einem Quellverzeichnis in ein Zielverzeichnis zu verschieben, basierend auf einem optionalen Regex-Muster, das typischerweise vierstellige Jahreszahlen am Anfang des Verzeichnisnamens identifiziert. Es ermittelt die Gesamtgröße der zu verschiebenden Verzeichnisse, führt die Verschiebung durch und bietet laufende Fortschrittsinformationen.
### Voraussetzungen
- PowerShell
- Zugriff auf Quell- und Zielverzeichnisse
### Technische Umsetzung
Das Skript nimmt folgende Parameter entgegen:
- **QuellVerzeichnis**: Das Verzeichnis, aus dem die Dateien verschoben werden.
- **ZielVerzeichnis**: Das Verzeichnis, in das die Dateien verschoben werden.
- **regexPattern**: Optional. Ein Regex-Muster zur Identifizierung der zu verschiebenden Verzeichnisse. Standardmäßig auf `"^\d{4} -"` gesetzt, um Verzeichnisse zu finden, die mit einer vierstelligen Jahreszahl beginnen.

Das Skript filtert Verzeichnisse im Quellverzeichnis basierend auf dem Regex-Muster, berechnet die Gesamtgröße dieser Verzeichnisse und verschiebt sie dann einzeln ins Zielverzeichnis. Bei Namenskonflikten werden die Verzeichnisse umbenannt. Es wird ein kontinuierlicher Fortschrittsbericht einschließlich Transfergeschwindigkeit und geschätzter verbleibender Zeit bereitgestellt.
### Funktionen und Parameter
- **Get-ChildItem**: Holt die Verzeichnisse im Quellverzeichnis und filtert sie basierend auf dem Regex-Muster.
- **Measure-Object**: Berechnet die Gesamtgröße der zu verschiebenden Verzeichnisse.
- **Move-Item**: Verschiebt die Verzeichnisse ins Zielverzeichnis.
- **Join-Path**: Baut den Pfad für die verschobenen Verzeichnisse im Zielverzeichnis.
- **Test-Path**: Überprüft, ob ein Verzeichnis im Zielverzeichnis bereits existiert, um Namenskonflikte zu vermeiden.
### Beispiele
Um Verzeichnisse aus dem Quellverzeichnis `"y:\_Filme\"` ins Zielverzeichnis `"n:\"` zu verschieben, die mit einer vierstelligen Jahreszahl beginnen:
> .\MoveFoldersByRegex.ps1 -QuellVerzeichnis "y:\_Filme\" -ZielVerzeichnis "n:\" -regexPattern "^\d{4} -"
### Versionshistorie
- 2024-04-03 - 1.0 - Erste Version
Dieses Skript optimiert die Organisation von Verzeichnissen durch automatisiertes Verschieben basierend auf benutzerdefinierten Kriterien und erleichtert somit die Verwaltung großer Datenmengen.

## [DetectAndManageDuplicateFiles.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/DetectAndManageDuplicateFiles.ps1)
### Kurzbeschreibung
Dieses PowerShell-Skript ist entworfen, um Dateien in einem Zielverzeichnis basierend auf ihrer Häufigkeit zu analysieren und optional zu löschen. Es durchläuft rekursiv alle Dateien, zählt die Vorkommen jeder Datei und zeigt Dateien an, die häufiger als ein definierter Schwellenwert auftreten. Bei Bedarf können diese Dateien auch gelöscht werden.
### Voraussetzungen
- PowerShell
- Zugriff auf das Zielverzeichnis

### Technische Umsetzung
Das Skript akzeptiert drei Parameter:
- **Zielverzeichnis**: Verpflichtend. Definiert das Verzeichnis, in dem Dateien analysiert (und optional gelöscht) werden.
- **delete**: Optional. Boolean-Wert, der angibt, ob Dateien gelöscht werden sollen. Standardmäßig auf `$false` gesetzt.
- **Anzahl**: Optional. Definiert den Schwellenwert für die Anzahl der Vorkommen einer Datei, ab dem Aktionen ergriffen werden. Standardmäßig auf `2` gesetzt.

Es sammelt rekursiv alle Dateien im Zielverzeichnis, zählt ihre Vorkommen und speichert diese in einer Hashtabelle. Anschließend werden Dateien, die häufiger als der Schwellenwert vorkommen, aufgelistet und optional gelöscht.
### Funktionen und Parameter
- **Get-ChildItem**: Wird genutzt, um alle Dateien im Zielverzeichnis rekursiv zu sammeln.
- **Foreach-Loop**: Durchläuft jede Datei, zählt Vorkommen und fügt diese in eine Hashtabelle ein.
- **Where-Object**: Filtert Dateien, die öfter als der Schwellenwert vorkommen.
- **Sort-Object**: Sortiert die gefilterten Dateien absteigend nach ihrer Anzahl.
- **Format-Table**: Stellt die Liste der Dateien und ihre Anzahl übersichtlich dar.
- **Remove-Item**: Löscht Dateien, die häufiger als der Schwellenwert vorkommen, wenn `delete` auf `$true` gesetzt ist.
### Beispiele
Um das Skript im Zielverzeichnis "n:\_neu\" auszuführen und Dateien, die öfter als zweimal vorkommen, zu löschen:
> .\DateiHäufigkeitsAnalysator.ps1 -Zielverzeichnis "n:\_neu\" -delete $true -Anzahl 2
### Versionshistorie
- 2021-05-16 - 1.0 - Erste Version
Dieses Skript bietet eine nützliche Lösung für die Verwaltung von Dateien basierend auf ihrer Häufigkeit, mit der Möglichkeit, Redundanzen automatisch zu bereinigen.

## [DistributeFilesIntoFolders.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/DistributeFilesIntoFolders.ps1)
### Kurzbeschreibung
Dieses PowerShell-Skript ist entworfen, um Dateien in einem Startverzeichnis in Unterordner zu sortieren, basierend auf einer definierten maximalen Anzahl von Dateien pro Unterordner. Dateinamen werden vor dem Verschieben sanitisiert, um ungültige Zeichen zu entfernen und eine sichere Dateibenennung zu gewährleisten.
### Voraussetzungen
- PowerShell
- Zugriff auf das Startverzeichnis
### Technische Umsetzung
Das Skript nimmt zwei Parameter entgegen:
- **startPath**: Optional. Der Pfad, von dem aus die Dateien organisiert werden sollen. Standardmäßig auf `"i:\"` gesetzt.
- **filesCount**: Optional. Die maximale Anzahl von Dateien pro Unterordner. Standardmäßig auf `150` gesetzt.

Es überprüft, ob der Startpfad existiert, und sortiert dann alle Dateien nach ihrem Erstellungsdatum. Anschließend werden neue Unterordner erstellt, in die die Dateien basierend auf dem `filesCount`-Parameter verteilt werden. Die Funktion `Sanitize-FileName` wird verwendet, um Dateinamen von ungültigen Zeichen zu bereinigen.
### Funktionen und Parameter
- **Test-Path**: Überprüft die Existenz des Startpfads und der Dateien.
- **Get-ChildItem**: Sammelt alle Dateien im Startpfad.
- **Sort-Object**: Sortiert die Dateien nach ihrem Erstellungsdatum.
- **New-Item**: Erstellt neue Unterordner im Startpfad.
- **Move-Item**: Verschiebt die Dateien in die entsprechenden Unterordner.
- **Sanitize-FileName**: Bereinigt Dateinamen von ungültigen Zeichen.

### Beispiele
Um das Skript mit dem Startverzeichnis `"i:\"` und einer maximalen Dateianzahl von `150` pro Unterordner auszuführen:
> .\DateiOrganisator.ps1 -startPath "i:\" -filesCount 150
### Versionshistorie
- 2023-12-10 - 1.0 - Erste Version

Dieses Skript ermöglicht eine effiziente Organisation von Dateien in größeren Verzeichnissen, indem es diese automatisch in handhabbare Unterordner sortiert, wodurch die Übersichtlichkeit und Zugänglichkeit verbessert wird.

## [OrganizeFoldersByRegex.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/OrganizeFoldersByRegex.ps1)

### Kurzbeschreibung
Dieses PowerShell-Skript organisiert Unterordner in einem Startverzeichnis, indem es diese basierend auf einem Regex-Muster in neu erstellte Zielordner verschiebt. Die Zielordner werden nach dem Muster benannt und im Startverzeichnis erstellt. Dies erleichtert die Sortierung und Organisation von Verzeichnissen nach bestimmten Kriterien, wie z.B. Jahreszahlen oder bestimmten Präfixen im Namen.

### Voraussetzungen
- PowerShell
- Zugriff auf das Startverzeichnis

### Technische Umsetzung
Das Skript akzeptiert zwei Parameter:
- **startdir**: Verpflichtend. Gibt das Startverzeichnis an, von dem aus die Ordner sortiert werden sollen.
- **Regex**: Optional. Das Regex-Muster zur Identifizierung der zu sortierenden Verzeichnisse. Standardmäßig auf `'^\d{4}'` gesetzt, um Verzeichnisse zu identifizieren, die mit einer vierstelligen Jahreszahl beginnen.

Es durchläuft alle Unterordner im Startverzeichnis und prüft, ob ihre Namen mit dem Regex-Muster übereinstimmen. Passende Verzeichnisse werden dann in neu erstellte Zielordner verschoben, die nach dem identifizierten Muster benannt sind.

### Funktionen und Parameter
- **Get-ChildItem**: Holt alle Unterordner im Startverzeichnis.
- **Test-Path**: Überprüft, ob das Zielverzeichnis bereits existiert.
- **New-Item**: Erstellt das Zielverzeichnis, falls es noch nicht existiert.
- **Move-Item**: Verschiebt die entsprechenden Verzeichnisse in das Zielverzeichnis.

### Beispiele
Um alle Unterordner, die mit einer vierstelligen Jahreszahl beginnen, im Verzeichnis `"n:\"` zu organisieren:
> .\OrganizeFoldersByRegex.ps1 -startdir "n:\"

Um alle Unterordner, deren Namen mit `"Musik - "` beginnen, im Verzeichnis `"n:\"` zu organisieren:
> .\OrganizeFoldersByRegex.ps1 -startdir "n:\" -Regex "^Musik - "

### Versionshistorie
- 2022-10-15 - 1.1 - Aktualisierte Version

Dieses Skript bietet eine flexible und effiziente Methode zur Organisation und Strukturierung von Dateisystemen, die sich besonders für große Sammlungen von Dateien und Ordnern eignet.)

## [extract_rar.ps1](https://github.com/ErhardRainer/powershell_FileOperations/blob/main/extract_rar.ps1)
### Kurzbeschreibung
Das Skript `RarEntpacker.ps1` durchsucht angegebene Startverzeichnisse nach RAR-Dateien, einschließlich Teilen von mehrteiligen RAR-Archiven, und entpackt diese automatisch mit 7-Zip. Es validiert den Entpackungsprozess, indem es überprüft, ob die Größe des Verzeichnisses nach dem Entpacken wie erwartet gestiegen ist. Bei erfolgreicher Entpackung besteht optional die Möglichkeit, die RAR-Dateien zu löschen.

### Voraussetzungen
- PowerShell
- 7-Zip muss installiert sein und der Pfad zur 7-Zip-Exe-Datei muss bekannt sein

### Technische Umsetzung
Das Skript nimmt folgende Parameter entgegen:
- **startdirs**: Verpflichtend. Ein Array von Startverzeichnissen, in denen nach RAR-Dateien gesucht werden soll.
- **PfadZu7Zip**: Optional. Der Pfad zur 7-Zip-Executable. Standardmäßig ist `"C:\Program Files\7-Zip\7z.exe"` eingestellt.
- **password**: Optional. Das Passwort für die RAR-Dateien, falls erforderlich.

Es sucht nach .rar Dateien, die den Namenskonventionen für mehrteilige Archive entsprechen (z.B. .part1.rar, .part01.rar), und entpackt diese. Anschließend wird die Größe des Verzeichnisses überprüft, um den Erfolg des Entpackungsvorgangs zu bestätigen. 

### Funktionen und Parameter
- **Get-ChildItem**: Durchsucht die Verzeichnisse nach RAR-Dateien.
- **Start-Process**: Startet den 7-Zip-Prozess zur Entpackung der gefundenen RAR-Dateien.
- **Get-DirectorySize**: Eine benutzerdefinierte Funktion zur Ermittlung der Größe eines Verzeichnisses in Gigabyte.

### Beispiele
Um RAR-Dateien in den Verzeichnissen "j:\Path\To\Series\S01\" und "j:\Path\To\Series\S02\" mit einem spezifischen Passwort zu entpacken:
> .\extract_rar.ps1 -startdirs @("j:\Path\To\Series\S01\", "j:\Path\To\Series\S02\") -PfadZu7Zip "C:\Program Files\7-Zip\7z.exe" -password "yourpassword"
### Versionshistorie
- 2023-09-16 - Initiale Version

Dieses Skript bietet eine automatisierte Lösung zur Verwaltung und Entpackung von RAR-Archiven, insbesondere für große Sammlungen oder Archive, die in mehrere Dateien aufgeteilt sind, und trägt so zur Effizienzsteigerung bei der Dateiverwaltung bei.
