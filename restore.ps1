# Macht alle Aenderungen von debloat.ps1 rueckgaengig.
# Aufruf:  powershell -ExecutionPolicy Bypass -File restore.ps1 -TvIp 192.168.1.50
# Voraussetzung: ADB-Debugging am Fernseher ist eingeschaltet, adb liegt im PATH
# oder wird ueber -Adb angegeben.
param(
    [Parameter(Mandatory = $true)][string]$TvIp,
    [string]$Adb = 'adb'
)

$packages = Get-Content (Join-Path $PSScriptRoot 'packages.txt') | Where-Object { $_ -and -not $_.StartsWith('#') }

& $Adb connect "${TvIp}:5555"

foreach ($p in $packages) { & $Adb shell pm enable $p }

# Home-Umleitung (Home on Fire) und Projectivy Launcher wieder entfernen
& $Adb uninstall io.github.toolicious.homeonfire
& $Adb uninstall com.spocky.projengmenu

# Werbeblockenden DNS abschalten
& $Adb shell settings put global private_dns_mode opportunistic
& $Adb shell settings delete global private_dns_specifier

Write-Host 'Fertig. Bitte den Fernseher einmal neu starten.'
