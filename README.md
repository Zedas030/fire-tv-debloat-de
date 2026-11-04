# Fire TV entschlacken

Zwei PowerShell-Skripte, die einen Amazon Fire TV per ADB von Werbung, Telemetrie,
vorinstallierten Apps und dem HbbTV-Browser befreien, einen werbeblockenden DNS setzen
und das Ganze auf Wunsch wieder vollständig rückgängig machen. Kein Root, nichts wird
gelöscht: die Pakete werden nur für den Benutzer deaktiviert.

Entstanden im Oktober 2026 für einen Smart-TV mit eingebautem Fire TV (Fire OS 8.1, Android 11).
Seitdem startet der Fernseher ohne Werbebanner direkt in einen eigenen Launcher. Getestet ist es
nur auf diesem Gerät. Andere Fire-TV-Geräte haben teils andere Pakete, siehe Fehlerbehebung.

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
- IP-Adresse des Geräts (steht unter *Einstellungen → Mein Fire TV → Info → Netzwerk*).

## Benutzung

```powershell
# Entschlacken (fragt beim ersten Mal am Fernseher nach der ADB-Freigabe)
powershell -ExecutionPolicy Bypass -File debloat.ps1 -TvIp <tv-ip>

# Ohne DNS-Änderung
powershell -ExecutionPolicy Bypass -File debloat.ps1 -TvIp <tv-ip> -NoDns

# Alles zurück
powershell -ExecutionPolicy Bypass -File restore.ps1 -TvIp <tv-ip>
```

`debloat.ps1` legt `disabled-before.txt` und `disabled-after.txt` neben sich ab, damit man
sieht, was sich geändert hat. Danach das Gerät einmal neu starten.

## Was erhalten bleibt

Streaming-Apps, App-Store, Einstellungen, Bluetooth-Fernbedienung, Sprachsteuerung und Updates von
Fire OS laufen normal weiter. Deaktiviert werden nur Werbeflächen, Telemetrie, Demo-Inhalte,
Tutorials und der HbbTV-Browser. Wer HbbTV-Mediatheken über den roten Knopf braucht, nimmt die
`com.vewd.*`-Zeilen aus `packages.txt` heraus.

## Fehlerbehebung

| Symptom | Ursache und Lösung |
|---|---|
| `unauthorized` bei `adb connect` | Am Fernseher erscheint eine Abfrage „USB-Debugging zulassen?“. Bestätigen, am besten mit „Immer zulassen“, dann erneut starten. |
| `failed to connect` / Zeitüberschreitung | Fernseher im Standby oder andere IP. Fernseher einschalten, IP unter *Mein Fire TV → Info → Netzwerk* prüfen. |
| `Unknown package` bei einzelnen Zeilen | Das Paket gibt es auf diesem Modell oder dieser Fire-OS-Version nicht. Harmlos, das Skript macht weiter. |
| Werbung ist nach einem Update zurück | Fire OS hat Pakete wieder aktiviert. `debloat.ps1` erneut ausführen und `disabled-after.txt` vergleichen. |
| Home-Taste öffnet wieder den Amazon-Startbildschirm | Home on Fire nach dem Update einmal öffnen, damit es die Taste wieder abfängt. |

## Zugangsdaten und eigene Werte

Die Skripte brauchen keine Zugangsdaten. Die Freigabe erteilt man einmal am Fernseher, wenn ADB sich zum
ersten Mal verbindet. Die IP-Adresse des eigenen Geräts ist im Repo ein Platzhalter:

| Was | Im Repo | Wo der eigene Wert hingehört |
|---|---|---|
| IP-Adresse des Fire TV | `<tv-ip>` | Parameter `-TvIp` beim Aufruf von `debloat.ps1` und `restore.ps1` |
| werbeblockender DNS | Standard `dns.adguard-dns.com` | Parameter `-Dns`, oder `-NoDns`, um nichts zu ändern |
| Pfad zu `adb` | Standard `adb` aus dem `PATH` | Parameter `-Adb` |
| Paketliste | [`packages.txt`](packages.txt) | Zeilen entfernen, die man behalten will, etwa `com.vewd.*` für HbbTV |

## Gelernt

- `pm disable-user` reicht. Deinstallieren (`pm uninstall -k --user 0`) macht Updates
  von Fire OS gern kaputt und lässt sich schlechter zurücknehmen.
- Nach einem Fire-OS-Update einige Pakete erneut prüfen, Amazon aktiviert manche wieder.
- Private DNS auf dem Fire TV ist versteckt, aber per `settings put global` erreichbar.
- Die Home-Taste lässt sich ohne Root nicht umbelegen, Home on Fire fängt sie aber ab.

## Lizenz

MIT, siehe [LICENSE](LICENSE).
