# Fire TV entschlacken

Zwei PowerShell-Skripte, die einen Amazon Fire TV per ADB von Werbung, Telemetrie,
vorinstallierten Apps und dem HbbTV-Browser befreien, einen werbeblockenden DNS setzen
und das Ganze auf Wunsch wieder vollständig rückgängig machen. Kein Root, nichts wird
gelöscht: die Pakete werden nur für den Benutzer deaktiviert.

Entstanden im Oktober 2026 für einen Fire TV Stick 4K (Fire OS 8). Seitdem startet der
Stick ohne Werbebanner direkt in einen eigenen Launcher.

## Was passiert

| Schritt | Mittel | Rückgängig |
|---|---|---|
| 28 Amazon-/Vewd-Pakete deaktivieren (Liste in [packages.txt](packages.txt)) | `pm disable-user --user 0` | `pm enable` |
| Werbeblockender DNS (Standard: AdGuard) | `settings put global private_dns_*` | Modus zurück auf `opportunistic` |
| Eigener Startbildschirm: **Home on Fire** leitet die Home-Taste um, **Projectivy Launcher** ist der neue Launcher | APKs von den jeweiligen Projekten, per `adb install` | `adb uninstall` |

Die beiden Launcher-Apps sind nicht Teil dieses Repos. Sie stammen von ihren Autoren
(Pakete `io.github.toolicious.homeonfire` und `com.spocky.projengmenu`) und werden von dort
installiert.

## Voraussetzungen

- Am Fire TV: *Einstellungen → Mein Fire TV → Entwickleroptionen → ADB-Debugging* ein.
- Am PC: Android Platform Tools (`adb`) im `PATH`, oder Pfad per `-Adb` übergeben.
- IP-Adresse des Sticks (steht unter *Einstellungen → Mein Fire TV → Info → Netzwerk*).

## Benutzung

```powershell
# Entschlacken (fragt beim ersten Mal am Fernseher nach der ADB-Freigabe)
powershell -ExecutionPolicy Bypass -File debloat.ps1 -TvIp 192.168.1.50

# Ohne DNS-Änderung
powershell -ExecutionPolicy Bypass -File debloat.ps1 -TvIp 192.168.1.50 -NoDns

# Alles zurück
powershell -ExecutionPolicy Bypass -File restore.ps1 -TvIp 192.168.1.50
```

`debloat.ps1` legt `disabled-before.txt` und `disabled-after.txt` neben sich ab, damit man
sieht, was sich geändert hat. Danach den Stick einmal neu starten.

## Gelernt

- `pm disable-user` reicht. Deinstallieren (`pm uninstall -k --user 0`) macht Updates
  von Fire OS gern kaputt und lässt sich schlechter zurücknehmen.
- Nach einem Fire-OS-Update einige Pakete erneut prüfen, Amazon aktiviert manche wieder.
- Private DNS auf dem Fire TV ist versteckt, aber per `settings put global` erreichbar.
- Die Home-Taste lässt sich ohne Root nicht umbelegen, Home on Fire fängt sie aber ab.

## Lizenz

MIT, siehe [LICENSE](LICENSE).
