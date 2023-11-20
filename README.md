# usb-backup

Minimalistische Datensicherung des Benutzerverzeichnisses auf USB Laufwerke mit Linux Bordmitteln.

## Kompatibilität

Getestet für
* Ubuntu 22.04

## Erfordnisse

* Systemd
* rsync
* bash

## Funktionen

* Sichert die Daten im Home Verzeichnis des Benutzers auf einem USB Laufwerk getrennt nach Rechner und Benutzer
* Die Sicherung wird gestartet, sobald ein bekanntes USB Laufwerk angeschlossen wird.
* Ausführliche Protokollierung der Sicherung
* Benachrichtigung über den Verlauf der Sicherung im Benachrichtigungsfeld des Windowmanagers
* Automatische Installation
* Berücksichtigung einer Liste von Verzeichnissen und Dateien, die von der Sicherung ausgeschlossen werden.

### TODO

 * Inkrementelles Backup
 * Backup in ein verschlüsseltes und kompromiertes tar kopieren.

## Nicht Funktionen

* Kein inkrementelles Backup; es wird nur ein Spiegel angelegt
* Es findet keine Prüfung statt, ob genügend freier Speicher auf dem USB Laufwerk für die Sicherung vorhanden ist. Das Backup sollte in diesem Fall mit einer Fehlermeldung beendet werden (*nicht getestet*)
* Backups werden nicht komprimiert.
* Backups werden nicht verschlüsselt. Abhilfe schafft aber ein verschlüsseltes USB Laufwerk. (Empfohlen)
* Es gibt keine Restore Funktion. Zur Wiederherstellung können die Daten aus der Sicherung einfach kopiert werden.

## Einschränkungen

* Die Installation richtet die Sicherung nur für ein USB Laufwerk ein.
* Die Ausschlussliste wird zum Installationszeitpunkt generiert, sollte aber besser bei der Ausführung erstellt werden.
* Das geht natürlich alles nur, wenn das USB Laufwerk automatisch eingebunden wird. Mit Ubunut Desktop geht's natürlich.

## Hintergrund

Technisch basiert dieses Verfahren auf Systemd. Der Backup Service ist abhängig von einer Mount Unit. Die Mount Unit wird von Systemd automatisch für Wechseldatenträger erstellt, wenn diese an den Rechner angeschlossen werden. Der Backup Service wird gestartet, wenn der Wechseldatenträger eingehängt wird. Der Backup Service startet ein Skript, das die Datensicherung durchführt.

## Verzeichnisstruktur der Sicherungen

*USB Backup* legt die Sicherungen auf dem Laufwerk nach folgender Struktur an:

```
/$HOSTNAME/$USERNAME
```

Für jeden Rechner und jeden Benutzer wird automatisch ein eigenes Verzeichnis für die Datensicherung auf dem Ziellaufwerk angelegt.

## Installation

1. Stecke das USB Laufwerk in den Rechner
2. Finde den Einhängepunkt des USB Laufwerks. Unter Ubuntu findest Du diesen i.d.R. unter `/media/$USER/` 
3. Hänge das USB Laufwerk vor der Installation wieder aus.
4. Führe das Installationsskript aus und übergebe den Pfad des Einhängepunkts. Z.B: `./install.sh /media/$USER/Sicherung`
5. Bearbeite die Ausschlussliste in der Datei `$HOME/.config/usb-backup/excludes`. Sie enthält eine Liste aller Dateien und Verzeichnisse, die nicht gesichert werden sollen. Die Datei enthält Muster für Dateien und Verzeichnisse, die von der Sicherung ausgenommen sind. Eine Beschreibung des Formats befindet sich im [rsync Handbuch](https://linux.die.net/man/1/rsync). 

## Sicherungsprotokoll

Das Protokoll des Dienstes lässt sich mit folgendem Befehl anzeigen:

```
journalctl --user -xef -u backup.service
```

## Backup Service neu starten

Nach einer Aktualisierung des Backup Service kann es erforderlich sein, diesen neu zu starten:

```bash
systemctl --user restart backup.service
```

Der Neustart des Services bewirkt auch, dass die Sicherung sofort ausgeführt wird, wenn das entsprechende USB Laufwerk eingebunden ist.
