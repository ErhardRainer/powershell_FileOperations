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
