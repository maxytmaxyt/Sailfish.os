# Sailfish OS Custom OTA Repository

Dieses Repository dient als automatisierte Build- und Distribution-Pipeline für eigene Sailfish OS RPM-Pakete (z. B. UI-Patches für das Sony Xperia 10).

## 📁 Repository-Struktur

Nein, du kannst nicht *einfach nur* lose Dateien ins Repo werfen. Linux-Paketmanager (wie `zypper` / `pkcon` in Sailfish) verstehen nur `.rpm`-Dateien. 

Es gibt zwei Wege, wie du das Strukturieren kannst:

### Option A: Quellcode + RPM-Spec (Automatischer Build)
Der sauberste Weg. Du legst deine geänderten QML-Dateien ab und gibst eine `.spec`-Datei an. GitHub Actions baut daraus automatisch das RPM.

```text
.
├── .github/
│   └── workflows/
│       └── build-repo.yml      # GitHub Actions Workflow
├── rpm/
│   └── custom-lipstick-mod.spec # Bauanleitung für das RPM-Paket
├── src/
│   └── EdgeLayer.qml           # Deine Modifizierte QML-Datei
└── README.md
```

### Option B: Pre-built RPMs (Direktes Reinschmeißen)
Wenn du RPMs lokal auf deinem PC baust, kannst du sie direkt im Repo ablegen (z. B. im Ordner `rpms/`).

```text
.
├── .github/
│   └── workflows/
│       └── build-repo.yml      # Packt nur createrepo_c darüber
├── rpms/
│   └── custom-lipstick-mod-1.0.0-1.noarch.rpm
└── README.md
```

---

## 🛠️ Einbindung auf dem Sony Xperia 10

Führe diese Schritte einmalig auf deinem Xperia 10 aus (SSH oder Terminal-App).

### 1. Entwicklermodus & Root aktivieren
Gehe in den Einstellungen auf **Entwickleroptionen**, aktiviere den Entwicklermodus und setze ein Passwort für SSH/Root.

### 2. Repository in SSU eintragen
```bash
# Zu Root wechseln
devel-su

# Dein GitHub Pages OTA Repo hinzufügen
ssu ar my-custom-ota https://<dein-github-username>.github.io/<repo-name>/

# SSU Repositories aktualisieren
ssu ur

# Paketmanager Cache leeren
pkcon refresh
```

---

## 🔄 Updates installieren

Sobald ein neuer Push auf `main` geht und GitHub Actions das Paket aktualisiert hat:

### Option 1: Vollständiges System-Update
```bash
version --dup
```

### Option 2: Gezieltes Paket-Update (Empfohlen für schnelle UI-Tests)
```bash
pkcon update custom-lipstick-mod
```

### UI neu starten (ohne Reboot)
```bash
systemctl --user restart lipstick
```
