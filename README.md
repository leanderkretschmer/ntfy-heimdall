# Proxmox und Docker Monitoring Skript

Dieses Skript überwacht den Status deiner Proxmox VMs und/oder Docker Container und sendet dir Benachrichtigungen über [ntfy.sh](https://ntfy.sh). So bleibst du informiert, wenn etwas nicht wie erwartet läuft.

## Was dieses Skript kann (Features)

*   **Proxmox VM Überwachung:**  Erkennt, ob deine virtuellen Maschinen laufen (`Running`) oder gestoppt sind (`Stopped`).  (Nur für `monitor.sh`)
*   **Docker Container Überwachung:**  Überwacht den Status deiner Container: `Running`, `Stopped` oder `Restarting`.
*   **Benachrichtigungen:**  Sendet sofortige Benachrichtigungen über ntfy.sh, wenn sich der Status einer VM oder eines Containers ändert.
*   **Blacklist:**  Du kannst bestimmte VMs oder Container von der Überwachung ausschließen. Das ist nützlich für Testsysteme oder unwichtige Container.
*   **Statusdatei:**  Erzeugt eine leicht lesbare Datei, die den aktuellen Status aller überwachten VMs und Container anzeigt.
*   **Zwei Varianten:**
    *   `monitor.sh`:  Für die Überwachung von *sowohl* Proxmox VMs als auch Docker Containern.
    *   `docker_monitor.sh`:  Für die Überwachung von *nur* Docker Containern.  Ideal, wenn du keinen Proxmox Server hast.
*   **Festplattenüberwachung:** Überwacht den Füllstand von Festplatten und gibt eine Warnung aus, wenn ein bestimmter Schwellwert unterschritten wurde.
*   **Temperaturüberwachung:** Überwacht die Temperatur der CPU und gibt eine Warnung aus, wenn ein bestimmter Schwellwert überschritten wurde.

## Was du brauchst (Voraussetzungen)

*   **Proxmox Server:**  Wird nur für das `monitor.sh` Skript benötigt.
*   **Docker:**  Docker muss installiert und eingerichtet sein, wenn du Docker Container überwachen möchtest.
*   **`curl`:**  `curl` muss installiert sein, da es für die Kommunikation mit ntfy.sh verwendet wird.
*   **ntfy.sh Account:**  Ein kostenloser Account bei [ntfy.sh](https://ntfy.sh) ist erforderlich, um Benachrichtigungen zu erhalten.

## So installierst du das Skript

1.  **Skript herunterladen:**

    Lade das/die passende(n) Skript(e) von diesem GitHub Repository herunter:

    *   `monitor.sh`:  Wenn du Proxmox VMs *und* Docker Container überwachen möchtest.
    *   `docker_monitor.sh`:  Wenn du *nur* Docker Container überwachen möchtest.

2.  **Skript ausführbar machen:**

    ```bash
    chmod +x monitor.sh  # oder docker_monitor.sh, je nachdem, welches Skript du verwendest
    ```

3.  **Verzeichnis für Statusdateien erstellen:**

    Erstelle einen Ordner, in dem das Skript die Statusdatei und andere Konfigurationsdateien speichert:

    ```bash
    mkdir -p /path/to/ntfy
    ```

    Ersetze `/path/to/ntfy` durch den tatsächlichen Pfad, z.B. `/home/deinbenutzername/ntfy`.

4.  **Blacklist-Datei erstellen (optional):**

    Wenn du bestimmte VMs oder Container *nicht* überwachen möchtest, erstelle eine Datei namens `blacklist.txt` in dem Verzeichnis, das du in Schritt 3 erstellt hast (`/path/to/ntfy`).  Trage in jede Zeile den Namen einer VM oder eines Containers ein, der ignoriert werden soll.

    Beispiel für den Inhalt der `blacklist.txt` Datei:

    ```
    test-container
    VM-XYZ
    ```

5.  **Skript konfigurieren:**

    Öffne das Skript `monitor.sh` *oder* `docker_monitor.sh` mit einem Texteditor und passe die folgenden Variablen an:

    *   `NTFY_TOPIC`:  Setze dies auf den Namen deines ntfy.sh Topics.  Dieser Name wird verwendet, um Benachrichtigungen an deine Geräte zu senden.
    *   `STATUS_FILE`:  Der Pfad zur Statusdatei (Standardwert: `/path/to/ntfy/status.txt`).  Du musst dies nur ändern, wenn du die Statusdatei an einem anderen Ort speichern möchtest.
    *   `BLACKLIST_FILE`:  Der Pfad zur Blacklist-Datei (Standardwert: `/path/to/ntfy/blacklist.txt`).  Auch hier gilt:  Ändere dies nur, wenn du die Blacklist-Datei an einem anderen Ort gespeichert hast.
    *   `DISK_CONFIG_FILE`:  Der Pfad zur `disk_config.txt` Datei (Standardwert: `/path/to/ntfy/disk_config.txt`).
    *   `TEMP_THRESHOLD_FILE`: Der Pfad zur `temp_threshold.txt` Datei (Standardwert: `/path/to/ntfy/temp_threshold.txt`).

## ntfy.sh Topic einrichten

1.  **ntfy.sh Webseite besuchen:**

    Öffne [ntfy.sh](https://ntfy.sh) in deinem Webbrowser.

2.  **Topic erstellen:**

    Gib einen Namen für dein Topic ein (z.B. `meinserver-monitoring`) und drücke die Enter-Taste.  Wähle einen Namen, der für dich leicht zu erkennen ist.

3.  **Topic abonnieren:**

    Befolge die Anweisungen auf der ntfy.sh Webseite, um das Topic mit der ntfy App auf deinem Smartphone oder Desktop zu abonnieren.  So erhältst du die Benachrichtigungen.

## Automatisierung mit Cronjob

Um das Skript automatisch in regelmäßigen Abständen auszuführen, verwende einen Cronjob.

1.  **Crontab öffnen:**

    ```bash
    crontab -e
    ```

2.  **Cronjob hinzufügen:**

    Füge eine der folgenden Zeilen hinzu, um das Skript jede Minute auszuführen:

    ```
    * * * * * /home/scripts/ntfy/monitor.sh   # Für Proxmox und Docker
    * * * * * /home/scripts/ntfy/docker_monitor.sh  # Für reines Docker Monitoring
    ```

    **Wichtig:**

    *   Passe den Pfad `/home/scripts/ntfy/` an den tatsächlichen Speicherort deines Skripts an.
    *   Wähle *nur eine* dieser Zeilen, je nachdem, welches Skript du verwendest.
    *   **Minuteninterval:** Die Zahl vor dem ersten Stern legt das Intervall fest. Du kannst das Skript auch nur alle 5 Minuten ausführen lassen, indem du `*/5 * * * *` verwendest.

3.  **Crontab speichern:**

    Speichere die Crontab-Datei.  Dein System wird das Skript nun automatisch ausführen.

## Die Statusdatei (`status.txt`)

Das Skript erstellt eine Datei namens `status.txt` in dem Verzeichnis, das du für die Konfiguration angegeben hast (`/path/to/ntfy`).  Diese Datei enthält den aktuellen Status aller überwachten VMs und/oder Container.  Du kannst diese Datei einsehen, um den Status auf einen Blick zu überprüfen.

## Die Blacklist-Datei (`blacklist.txt`) bearbeiten

Die `blacklist.txt` Datei ermöglicht es dir, bestimmte VMs oder Docker Container von der Überwachung auszuschließen.  Das ist nützlich, wenn du z.B. ein Testsystem hast, das du nicht überwachen möchtest.

Um einen Eintrag hinzuzufügen oder zu entfernen, öffne die Datei mit einem Texteditor (z.B. `nano` oder `vi`) und füge den Namen der VM oder des Containers in eine neue Zeile ein.  Speichere die Datei.  Das Skript liest die Blacklist-Datei bei jeder Ausführung und ignoriert alle Einträge, die dort aufgeführt sind.

## Die Disk-Konfigurationsdatei (`disk_config.txt`) erstellen und bearbeiten

Die `disk_config.txt` Datei ermöglicht es dir, den Füllstand bestimmter Festplatten zu überwachen und Benachrichtigungen zu erhalten, wenn der freie Speicherplatz unter einen bestimmten Wert fällt.

1.  **Datei erstellen:**

    Erstelle eine Datei namens `disk_config.txt` in dem Konfigurationsverzeichnis (`/path/to/ntfy`).

2.  **Einträge hinzufügen:**

    Füge in jeder Zeile den Pfad zum Mountpoint der Festplatte und den Schwellenwert (in MB) hinzu, getrennt durch ein Gleichheitszeichen (`=`):

    ```
    /pfad/zum/mountpoint=Schwellenwert_in_MB
    ```

    Beispiel für den Inhalt der `disk_config.txt` Datei:

    ```
    /var/log=1024  # Benachrichtigung, wenn weniger als 1024 MB (1 GB) frei sind
    /home=5120  # Benachrichtigung, wenn weniger als 5120 MB (5 GB) frei sind
    ```

    *Ersetze `/pfad/zum/mountpoint` durch den tatsächlichen Pfad, z.B. `/var/log` oder `/home`.*

3.  **Kommentare:**

    Du kannst Kommentare hinzufügen, indem du eine Zeile mit einem Hash-Zeichen (`#`) beginnst:

    ```
    # Dies ist ein Kommentar
    /var/log=1024  # Überwache /var/log auf weniger als 1 GB
    ```

## Temperaturüberwachung

Das Skript kann auch die CPU-Temperatur überwachen und Benachrichtigungen senden, wenn ein konfigurierter Schwellenwert überschritten wird.

1.  **`temp_threshold.txt` Datei erstellen:**

    Erstelle eine Datei namens `temp_threshold.txt` im Verzeichnis `/path/to/ntfy`.

2.  **Schwellenwert hinzufügen:**

    Füge in der ersten Zeile den Schwellenwert für die CPU-Temperatur in Grad Celsius hinzu:

    ```
    70
    ```

3.  **Node-Namen hinzufügen (optional):**

    Gehe dafür einfach in das haupt script und setze dort die Variable `NODE_NAME` auf den gewünschten namen.

## Fehlerbehebung

*   **Keine Benachrichtigungen erhalten:**
    *   Stelle sicher, dass dein ntfy.sh Topic korrekt eingerichtet ist und du den Topic mit der ntfy App abonniert hast.
    *   Überprüfe, ob das Skript korrekt ausgeführt wird (überprüfe die Cronjob-Einstellungen und die Logdateien, falls vorhanden).
    *   Überprüfe die Statusdatei, um sicherzustellen, dass das Skript den Status der VMs und Container korrekt erfasst.
    *   Überprüfe die Blacklist-Datei, um sicherzustellen, dass die VMs und Container, die du überwachen möchtest, nicht versehentlich ausgeschlossen wurden.
*   **Falsche Statusmeldungen:**
    *   Überprüfe die Statusdatei, um sicherzustellen, dass das Skript den Status der VMs und Container korrekt erfasst.
    *   Stelle sicher, dass die Zeit auf deinem Proxmox Server korrekt eingestellt ist (falsche Zeit kann zu falschen Statusmeldungen führen).

## Lizenz

Dieses Projekt ist unter der [MIT License](license.md) lizenziert.

## Haftungsausschluss

Die Nutzung dieses Skripts erfolgt auf eigene Gefahr. Der Autor übernimmt keine Verantwortung für Schäden, die durch die Nutzung dieses Skripts entstehen.

## Unterstützung

Bei Fragen oder Problemen kannst du ein Issue in diesem GitHub Repository erstellen.
