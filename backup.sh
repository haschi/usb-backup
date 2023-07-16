#!/usr/bin/env bash
set -e

# backup.sh target
#
# Das Skript synchronisiert die Daten im $HOME Verzeichniss mit
# einem Zielverzeichnis.
#
# Das Zielverzeichnis sollte der Einhängepunkt eines USB Laufwerks
# sein, kann aber jedes beliebige Verzeichnis sein, sollte aber 
# NICHT unterhalb des $HOME Verzeichnisses liegen, da sich das Backup
# in sich selbst kopieren würden.
#
# Der Parameter target muss ein existierendes Verzeichnis sein und
# wird vom backup.service automatisch übergeben (sofern diese dort 
# korrekt konfiguriert wurde.
#
# Die Ausgabe erfolgt im Terminal. Wenn das Skript über den backup.service
# gestartet wurde, ist die Ausgabe im systemd Journal zu finden:
# 
# journalctl --user -xef -u backup.service


on_exit () {
  error_code=$?

  if [ $error_code -eq 0 ]; then
    message="Backup erfolgreich ausgeführt"
    icon="dialog-information"
  else
    message="Fehler beim Erstellen des Backups. Error Code: $error_code"
    icon="dialog-error"
  fi

  # Ausgabe im Terminal oder Journal
  echo $message

  # Zusätzliche eine Benachrichtigung, falls interaktive Shell
  # (Das Skript wurde nicht von Systemd, sondern vom Anwender in
  # einer Shell aufgerufen.)
  notify-send --expire-time 4000 --icon "$icon" --urgency=normal "USB Backup" "$message"

  # TODO: Interaktice checken, Fehler Icon.
}


# trap "echo error; on_exit" ERR
trap on_exit EXIT

# see log with journalctl --user xef backup.service
echo "Ausführung: $0 $*"
echo "Einhängepunkt des Ziellaufwerks $1"
usage="Usage: $0 directory"
: ${1?$usage}

# Parameter prüfen
if [[ ! -d $1 ]]; then
  echo "Fehler: Das Verzeichnis $1 existiert nicht."
  exit 10
fi


# Wichtig: Ohne abschließendes /
TARGET_MOUNTPOINT="$1"
TARGET_DIRECTORY="$TARGET_MOUNTPOINT/$HOSTNAME/$USER"

notify-send --expire-time 4000 --urgency=normal "USB Backup" "Backup gestartet"
echo "Synchronisiere $HOME mit $TARGET_DIRECTORY"

# mkdir -p "$TARGET_DIRECTORY"
exclude_file=${XDG_CONFIG_HOME-$HOME/.config}/usb-backup/excludes

rsync --archive --verbose --delete "$HOME"/ "$TARGET_DIRECTORY" \
  --mkpath \
  --munge-links \
  --exclude-from=$exclude_file
