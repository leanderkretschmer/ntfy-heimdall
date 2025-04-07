# Proxmox und Docker Monitoring Script

Dieses Bash-Skript überwacht den Status von Proxmox VMs und/oder Docker Containern und sendet Benachrichtigungen über [ntfy.sh](https://ntfy.sh).

## Features

*   Überwacht den Status von Proxmox VMs (Running/Stopped).
*   Überwacht den Status von Docker Containern (Running/Stopped/Restarting).
*   Sendet Benachrichtigungen über ntfy.sh, wenn sich der Status einer VM oder eines Containers ändert.
*   Unterstützt eine Blacklist, um bestimmte VMs oder Container von der Überwachung auszuschließen.
*   Erzeugt eine menschenlesbare Statusdatei, die den aktuellen Status aller überwachten VMs und Container enthält.
*   **Zwei Skriptvarianten:**
    *   `monitor.sh`: Überwacht sowohl Proxmox VMs als auch Docker Container.
    *   `docker_monitor.sh`: Überwacht nur Docker Container (ideal für Umgebungen ohne Proxmox).

## Voraussetzungen

*   Ein Proxmox Server (nur für `monitor.sh`).
*   Docker installiert und konfiguriert (falls Docker Container überwacht werden sollen).
*   `curl` installiert.
*   Ein [ntfy.sh](https://ntfy.sh) Account (kostenlos).

## Installation

1.  **Skript(e) herunterladen:**

    Lade die gewünschte(n) Skriptdatei(en) von diesem GitHub Repository herunter:

    *   `monitor.sh`: Für Proxmox und Docker Monitoring.
    *   `docker_monitor.sh`: Für reines Docker Monitoring.

2.  **Skript ausführbar machen:**

    ```bash
    chmod +x monitor.sh  # Oder docker_monitor.sh, je nachdem welches Skript du verwendest
    ```

3.  **Verzeichnis für Statusdateien erstellen:**

    ```bash
    mkdir -p /path/to/ntfy
    ```

4.  **Blacklist-Datei erstellen (optional):**

    Wenn du bestimmte VMs oder Container von der Überwachung ausschließen möchtest, erstelle eine Datei namens `blacklist.txt` im Verzeichnis `/path/to/ntfy`. Füge in jeder Zeile den Namen einer VM oder eines Containers hinzu, die/der ausgeschlossen werden soll.

    Beispielinhalt der `blacklist.txt` Datei:

    ```
    test-container
    VM-XYZ
    ```

5.  **Skript konfigurieren:**

    Passe die folgenden Variablen im Skript `monitor.sh` *oder* `docker_monitor.sh` an:

    *   `NTFY_TOPIC`: Setze dies auf deinen ntfy.sh Topic Namen.
    *   `STATUS_FILE`: Der Pfad zur Statusdatei (standardmäßig `/path/to/ntfy/status.txt`).
    *   `BLACKLIST_FILE`: Der Pfad zur Blacklist-Datei (standardmäßig `/path/to/ntfy/blacklist.txt`).
    *   `DISK_CONFIG_FILE`: Der Pfad zur Blacklist-Datei (standardmäßig `/path/to/ntfy/disk_config.txt`).

## ntfy.sh Topic einrichten

1.  **ntfy.sh Webseite besuchen:**

    Gehe zu [ntfy.sh](https://ntfy.sh) in deinem Webbrowser.

2.  **Topic erstellen:**

    Gib deinen gewünschten Topic Namen ein (z.B. `myserver-monitor`) und drücke die Enter-Taste.

3.  **Topic abonnieren:**

    Befolge die Anweisungen auf der ntfy.sh Webseite, um den Topic mit der ntfy App auf deinem Smartphone oder Desktop zu abonnieren.

## Automatisierung mit Cronjob

Um das Skript automatisch auszuführen, kannst du einen Cronjob einrichten.

1.  **Crontab öffnen:**

    ```bash
    crontab -e
    ```

2.  **Cronjob hinzufügen:**

    Füge die folgende Zeile hinzu, um das Skript jede Minute auszuführen:

    ```
    * * * * * /home/scripts/ntfy/monitor.sh   # Für Proxmox und Docker
    * * * * * /home/scripts/ntfy/docker_monitor.sh  # Für reines Docker Monitoring
    ```

    Passe den Pfad und den Skriptnamen an den tatsächlichen Speicherort deines Skripts an. Wähle *nur eine* dieser Zeilen, je nachdem, welches Skript du verwenden möchtest.

3.  **Crontab speichern:**

    Speichere die Crontab-Datei.

## Statusdatei

Das Skript erzeugt eine Statusdatei namens `status.txt` im Verzeichnis `/path/to/ntfy`. Diese Datei enthält den aktuellen Status aller überwachten VMs und/oder Container.

Die Zeilenumbrüche im Dockerpart sehen doof aus, das lässt sich aber mit dem Format vom docker ps beheben, dafür ist aber dein docker ps befehl zuständig das musst du anpassen (also ich)

## Blacklist-Datei bearbeiten

Die `blacklist.txt` Datei ermöglicht es dir, bestimmte VMs oder Docker Container von der Überwachung auszuschließen. Um einen Eintrag hinzuzufügen, öffne die Datei mit einem Texteditor (z.B. `nano` oder `vi`) und füge den Namen der VM oder des Containers in eine neue Zeile ein. Speichere die Datei, nachdem du deine Änderungen vorgenommen hast. Das Skript liest die Blacklist-Datei bei jeder Ausführung und ignoriert alle Einträge, die in der Blacklist-Datei aufgeführt sind.

## Disk-Konfigurationsdatei erstellen und bearbeiten

Die `disk_config.txt` Datei ermöglicht es dir, den freien Speicherplatz auf bestimmten Festplatten zu überwachen und Benachrichtigungen zu erhalten, wenn ein Schwellenwert unterschritten wird.

1.  **Datei erstellen:**

    Erstelle eine Datei namens `disk_config.txt` im Verzeichnis `/path/to/ntfy`.

2.  **Einträge hinzufügen:**

    Füge in jeder Zeile den Pfad zum Mountpoint der Festplatte und den Schwellenwert (in MB) hinzu, getrennt durch ein Gleichheitszeichen (`=`):

    ```
    /pfad/zum/mountpoint=Schwellenwert_in_MB
    ```

    Beispielinhalt der `disk_config.txt` Datei:

    ```
    /var/log=1024  # Benachrichtigung, wenn weniger als 1024 MB (1 GB) frei sind
    /home=5120  # Benachrichtigung, wenn weniger als 5120 MB (5 GB) frei sind
    ```

3.  **Kommentare:**

    Du kannst Kommentare hinzufügen, indem du eine Zeile mit einem Hash-Zeichen (`#`) beginnst:

    ```
    # Dies ist ein Kommentar
    /var/log=1024  # Überwache /var/log auf weniger als 1 GB
    ```
## Fehlerbehebung

*   **Keine Benachrichtigungen erhalten:**
    *   Stelle sicher, dass dein ntfy.sh Topic korrekt eingerichtet ist und du den Topic mit der ntfy App abonniert hast.
    *   Überprüfe, ob das Skript korrekt ausgeführt wird (überprüfe die Cronjob-Einstellungen).
    *   Überprüfe die Statusdatei, um sicherzustellen, dass das Skript den Status der VMs und Container korrekt erfasst.
    *   Überprüfe die Blacklist-Datei, um sicherzustellen, dass die VMs und Container, die du überwachen möchtest, nicht versehentlich ausgeschlossen wurden.
*   **Falsche Statusmeldungen:**
    *   Überprüfe die Statusdatei, um sicherzustellen, dass das Skript den Status der VMs und Container korrekt erfasst.
    *   Stelle sicher, dass die Zeit auf deinem Proxmox Server korrekt eingestellt ist.

## Lizenz

Dieses Projekt ist unter der [MIT License](license.md) lizenziert.

## Haftungsausschluss

Die Nutzung dieses Skripts erfolgt auf eigene Gefahr. Der Autor übernimmt keine Verantwortung für Schäden, die durch die Nutzung dieses Skripts entstehen.

## Unterstützung

Bei Fragen oder Problemen kannst du ein Issue in diesem GitHub Repository erstellen.


