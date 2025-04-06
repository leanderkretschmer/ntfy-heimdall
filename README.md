# Proxmox und Docker Monitoring Script

Dieses Bash-Skript überwacht den Status von Proxmox VMs und Docker Containern und sendet Benachrichtigungen über [ntfy.sh](https://ntfy.sh).

## Features

*   Überwacht den Status von Proxmox VMs (Running/Stopped).
*   Überwacht den Status von Docker Containern (Running/Stopped/Restarting).
*   Sendet Benachrichtigungen über ntfy.sh, wenn sich der Status einer VM oder eines Containers ändert.
*   Unterstützt eine Blacklist, um bestimmte VMs oder Container von der Überwachung auszuschließen.
*   Erzeugt eine menschenlesbare Statusdatei, die den aktuellen Status aller überwachten VMs und Container enthält.

## Voraussetzungen

*   Ein Proxmox Server.
*   Docker installiert und konfiguriert (falls Docker Container überwacht werden sollen).
*   `curl` installiert.
*   Ein [ntfy.sh](https://ntfy.sh) Account (kostenlos).

## Installation

1.  **Skript herunterladen:**

    Lade das Skript `monitor.sh` von diesem GitHub Repository herunter.

2.  **Skript ausführbar machen:**

    ```bash
    chmod +x monitor.sh
    ```

3.  **Verzeichnis für Statusdateien erstellen:**

    ```bash
    mkdir -p /home/scripts/ntfy
    ```

4.  **Blacklist-Datei erstellen (optional):**

    Wenn du bestimmte VMs oder Container von der Überwachung ausschließen möchtest, erstelle eine Datei namens `blacklist.txt` im Verzeichnis `/home/scripts/ntfy`. Füge in jeder Zeile den Namen einer VM oder eines Containers hinzu, die/der ausgeschlossen werden soll.

    Beispielinhalt der `blacklist.txt` Datei:

    ```
    beszel-agent
    test-container
    VM-XYZ
    ```

5.  **Skript konfigurieren:**

    Passe die folgenden Variablen im Skript `monitor.sh` an:

    *   `NTFY_TOPIC`: Setze dies auf deinen ntfy.sh Topic Namen.
    *   `STATUS_FILE`: Der Pfad zur Statusdatei (standardmäßig `/home/scripts/ntfy/status.txt`).
    *   `BLACKLIST_FILE`: Der Pfad zur Blacklist-Datei (standardmäßig `/home/scripts/ntfy/blacklist.txt`).

## ntfy.sh Topic einrichten

1.  **ntfy.sh Webseite besuchen:**

    Gehe zu [ntfy.sh](https://ntfy.sh) in deinem Webbrowser.

2.  **Topic erstellen:**

    Gib deinen gewünschten Topic Namen ein (z.B. `pve-monitor`) und drücke die Enter-Taste.

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
    * * * * * /home/scripts/ntfy/monitor.sh
    ```

    Passe den Pfad `/home/scripts/ntfy/monitor.sh` an den tatsächlichen Speicherort deines Skripts an.

3.  **Crontab speichern:**

    Speichere die Crontab-Datei.

## Statusdatei

Das Skript erzeugt eine Statusdatei namens `status.txt` im Verzeichnis `/home/scripts/ntfy`. Diese Datei enthält den aktuellen Status aller überwachten VMs und Container. Die Datei ist menschenlesbar und im folgenden Format aufgebaut:

