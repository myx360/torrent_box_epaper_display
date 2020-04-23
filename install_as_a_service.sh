#!/bin/bash

[[ $EUID != 0 ]] && echo "Please run as root" && exit

echo "

Installs epaper display as a persistant systemd service using the current directory as a the run path. Requires root user to run.
To change the runpath for the service, disable the service, move the project directory, then re-run this script.
To completely remove the service, delete the file /lib/systemd/system/epaper_display.service.

Attempting install...."

PYTHON3_HOME=$(which python3)

[[ -z "$PYTHON3_HOME" ]] && echo "Could not find python3 command, service not installed"
[[ -z "$PWD" ]] && echo "Could not find current working directory, service not installed"
CONFIG_PATH="${PWD}/config.yml"

touch ${PWD}/config.yml
chown root "${CONFIG_PATH}"
chmod 600 "${CONFIG_PATH}"

echo "
In order to access your torrents list, this script will need access to the transmission CLI tool, which requires \
the transmission username and password. This will be stored (in plaintext) in: ${CONFIG_PATH}"

echo -n "username:"
read transmission_username
echo -n "password:"
read -s transmission_password

echo "username: ${transmission_username}
password: ${transmission_password}
" > "${CONFIG_PATH}"

echo "[Unit]
Description=Transmission Torrent E-paper Display
After=multi-user.target

[Service]
Type=idle
ExecStart=${PYTHON3_HOME} ${PWD}/main.py user pass
Restart=on-abort

[Install]
WantedBy=multi-user.target
" > /lib/systemd/system/epaper_display.service

chmod 644 /lib/systemd/system/epaper_display.service
systemctl daemon-reload

echo "Installation complete.

To start the service run:
	sudo systemctl start epaper_display

To stop the service run:
	sudo systemctl stop epaper_display

To start the service at boot, run:
	sudo systemctl enable epaper_display

To stop the service running at boot, run
	sudo systemctl disable epaper_display
"
