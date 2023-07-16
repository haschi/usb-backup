#!/bin/bash

shopt -s globstar
shopt -s dotglob


if [ ! -d "$1" ]; then
    echo "Kein Verzeichnis angegeben oder Verzeichnis existiert nicht: $1"
    exit 1
fi

mount_unit=$(systemd-escape -p --suffix=mount "$1" )
echo "Erstelle Backup Konfiguration für $mount_unit"


systemd_userdir="$HOME/.config/systemd/user"
echo Erstelle Verzeichnis $systemd_userdir
mkdir -p $HOME/.config/systemd/user

systemd_service="$systemd_userdir/backup.service"

# Prüfe, ob der Service bereits existiert und erstelle ggf.
# ein Backup dieser Datei.

if [ -f "$systemd_service" ]; then
    echo "Die Datei $systemd_service existiert bereits."
    backup="$systemd_service.$(date -Iseconds).bak"
    echo "Verschiebe $systemd_service nach $backup"
    mv $systemd_service $backup
fi

echo Generiere Backup Service $systemd_service

cat << EOF > $systemd_service
[Unit]
Description=Backup directory %h
RequiresMountsFor=$1

[Service]
ExecStart=%h/.local/bin/backup.sh "$1"

[Install]
WantedBy=$mount_unit
EOF


echo Generiere Ausschlussliste
config_dir=${XDG_CONFIG_HOME-$HOME/.config}/usb-backup
exclude_file=$config_dir/excludes

mkdir -p $config_dir
if [ ! -f "$exclude_file" ]; then
cat << EOF > $exclude_file
/.cache
/.vscode
/.local/share/Steam
Trash/
/snap
node_modules/
EOF

for i in $HOME/**/CACHEDIR.TAG; do
    if [ -f "$i" ]; then
        echo Verzeichnis $(dirname ${i#$HOME}) wird ausgeschlossen
        echo $(dirname ${i#$HOME}) >> $exclude_file
    fi
done

else
  echo Es existiert bereits eine Ausschlussliste. Es werden keine Änderungen ausgeführt
fi

echo Installiere Backup Skript
mkdir -p $HOME/.local/bin
cp backup.sh $HOME/.local/bin
chmod +x $HOME/.local/bin/backup.sh


echo "Aktiviere Backup Service"
systemctl --user enable backup.service

echo Fertig
