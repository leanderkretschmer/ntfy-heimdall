# Heimdall - Monitoring Roadmap

## Vision

Ein benutzerfreundliches, flexibles und umfassendes Monitoring-Tool für Proxmox und Docker, das Benachrichtigungen über verschiedene Kanäle (Discord, ntfy.sh) ermöglicht und einfach zu installieren und zu konfigurieren ist.

## Kernziele

*   **Einfache Einrichtung:** Automatisierte Installation und Konfiguration.
*   **Vielseitige Benachrichtigungen:** Unterstützung für Discord-Webhooks und ntfy.sh.
*   **Zentrale Konfiguration:** Alle Einstellungen in einer einzigen, leicht verständlichen Konfigurationsdatei.
*   **Erweiterbarkeit:** Modulare Architektur für einfache Integration neuer Features und Benachrichtigungskanäle.
*   **Zuverlässigkeit:** Robuste Fehlerbehandlung und stabile Ausführung.

## Roadmap

### Phase 1: Stabilisierung und Aufräumen (Aktuell)

*   **Ziel:** Den bestehenden Bash-Code stabilisieren und die Grundlage für zukünftige Erweiterungen schaffen.
*   **Aufgaben:**
    *   [X] **Fehlerbehebung:** Alle bekannten Bugs und Inkonsistenzen im Bash-Skript beheben.
    *   [X] **Refactoring:** Den Bash-Code übersichtlicher und wartungsfreundlicher gestalten.
    *   [X] **Dokumentation:** Eine umfassende [README.md](README.md) Datei erstellen, die die Installation, Konfiguration und Verwendung des Skripts erklärt.
    *   [X] **Lizenzierung:** Das Projekt unter einer Open-Source-Lizenz (z. B. MIT) veröffentlichen.

### Phase 2: Discord-Integration und Konfigurationsverbesserung

*   **Ziel:** Unterstützung für Discord-Webhooks hinzufügen und die Konfiguration vereinfachen.
*   **Aufgaben:**
    *   [X] **Discord-Webhook-Unterstützung:** Eine Option zum Senden von Benachrichtigungen über Discord-Webhooks anstelle von ntfy.sh hinzufügen.
    *   [ ] **ntfy.sh Authentifizierung:** Unterstützung für die Authentifizierung bei ntfy.sh hinzufügen, um private Topics zu verwenden.
    *   [X] **Einheitliche Konfigurationsdatei:** Alle Einstellungen (ntfy.sh Topic/Key, Blacklist, Festplatten, Temperatur) in einer einzigen Konfigurationsdatei zusammenführen.
    *   [ ] **Konfigurationsvalidierung:** Das Skript soll die Konfigurationsdatei auf Fehler überprüfen und aussagekräftige Fehlermeldungen ausgeben.

### Phase 3: Automatisierung und Benutzerfreundlichkeit

*   **Ziel:** Die Installation und Konfiguration des Tools so einfach wie möglich gestalten.
*   **Aufgaben:**
    *   [ ] **Installationsskript:** Ein interaktives Installationsskript erstellen, das alle erforderlichen Abhängigkeiten installiert, die Konfigurationsdatei erstellt und den Cronjob einrichtet.
    *   [ ] **Config über eine weboberfläche**
    *   [ ] **Interaktive Konfiguration:** Während der Installation die Möglichkeit bieten, die Konfiguration über eine Chat-ähnliche Oberfläche anzupassen.
    *   [ ] **Automatisches Update:** Eine Funktion zum automatischen Aktualisieren des Skripts aus dem GitHub Repository hinzufügen.

### Phase 4: C#-Neuentwicklung und modulare Architektur

*   **Ziel:** Das Skript in C# neu schreiben, um die Leistung, Wartbarkeit und Erweiterbarkeit zu verbessern.
*   **Aufgaben:**
    *   [ ] **C#-Neuentwicklung:** Das gesamte Skript in C# neu schreiben.
    *   [ ] **Modulare Architektur:** Eine modulare Architektur entwerfen, um die Integration neuer Features und Benachrichtigungskanäle zu erleichtern.
    *   [ ] **Erweiterte Überwachung:** Unterstützung für weitere Metriken (z. B. Netzwerkauslastung, Speicherauslastung) hinzufügen.

### Phase 5: Eigener Discord-Bot

*   **Ziel:** Entwicklung eines vollwertigen Discord-Bots für erweiterte Interaktion und Steuerung.
*   **Aufgaben:**
    *   [ ] **Discord-Bot-Integration:** Einen eigenen Discord-Bot entwickeln, der sich bei Discord anmeldet und Befehle entgegennehmen kann.
    *   [ ] **Chatbefehle:** Implementierung von Chatbefehlen zur Abfrage des Status, Ändern der Konfiguration und Ausführen anderer Aktionen.
    *   [ ] **Ereignisgesteuerte Benachrichtigungen:** Der Bot soll in Echtzeit auf Ereignisse reagieren (z. B. wenn eine VM offline geht) und Benachrichtigungen senden.

## Optionale Erweiterungen

*   **Weboberfläche:** Eine einfache Weboberfläche zur Anzeige des Systemstatus und zur Konfiguration des Skripts erstellen.
*   **Unterstützung für weitere Benachrichtigungskanäle:** Integration von Telegram, Slack, E-Mail usw.
*   **Benutzerdefinierte Metriken:** Die Möglichkeit bieten, eigene Überwachungsmetriken zu definieren und zu erfassen.

## Lizenz

Dieses Projekt ist unter der [MIT License](LICENSE) lizenziert.

## Haftungsausschluss

Die Nutzung dieses Skripts erfolgt auf eigene Gefahr. Der Autor übernimmt keine Verantwortung für Schäden, die durch die Nutzung dieses Skripts entstehen.

## Unterstützung

Bei Fragen oder Problemen kannst du ein Issue in diesem GitHub Repository erstellen.
