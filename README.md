# PowerShell-Skript zur Dateiverwaltung
## Überblick
Dieses PowerShell-Skript (bereinigeVerzeichnisse.ps1) ist für die automatisierte Verwaltung und Organisation von Dateien in einem spezifizierten Startverzeichnis konzipiert. Es nutzt 7-Zip zur Behandlung von .rar-Dateien und organisiert die Struktur von Unterverzeichnissen.

## Features
* Durchläuft rekursiv alle Unterverzeichnisse eines angegebenen Startpfades.
* Behandelt speziell .rar-Dateien: Überprüft, entpackt und löscht sie bei Erfolg.
* Strukturiert Unterverzeichnisse um: Verschiebt Dateien aus Unter-Unterverzeichnissen eine Ebene höher.
* Demo-Modus: Simuliert Aktionen ohne reale Dateioperationen.
## Voraussetzungen
* PowerShell
* 7-Zip installiert und im Systempfad verfügbar
## Verwendung
* Parameter
** StartPath: Der Pfad des Startverzeichnisses, von dem aus die Verarbeitung beginnt.
** demo: Wenn auf $true gesetzt, wird der Vorgang nur simuliert.
* Beispiele
.\bereinigeVerzeichnisse.ps1 -StartPath "D:\Ordner"
.\bereinigeVerzeichnisse.ps1 -StartPath "D:\Ordner" -demo $true

## Funktionsweise
### DurchlaufeVerzeichnisse
Durchläuft alle Unterverzeichnisse des angegebenen Verzeichnisses und ruft je nach Inhalt spezifische Behandlungsfunktionen auf.
### BehandleRarDateien
Behandelt Unterverzeichnisse, die .rar-Dateien enthalten. Überprüft auf Vollständigkeit, entpackt und löscht sie bei Erfolg.
### BehandleUnterverzeichnisse
Behandelt Unterverzeichnisse basierend auf der Anzahl und Art der Unter-Unterverzeichnisse. Verschiebt Dateien und strukturiert die Verzeichnisse um.

## Lizenz
Dieses Skript ist lizenziert unter.

## Autor
Erhard Rainer
