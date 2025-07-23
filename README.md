# cursor-installer-updater-ubuntu

```sh
sudo apt update && sudo apt install -y curl jq wget zenity dbus-x11
```

# Startup Applications
```txt
Name: Update Cursor
Command: systemctl --user start update-cursor.service
Comment: Start the update-cursor service at login
```
