# Entschlackt einen Fire TV (Werbung, Telemetrie, vorinstallierte Apps, HbbTV)
# und setzt einen werbeblockenden DNS. Alles ist mit restore.ps1 umkehrbar.
# Aufruf:  powershell -ExecutionPolicy Bypass -File debloat.ps1 -TvIp 192.168.1.50 [-Dns dns.adguard-dns.com]
# Voraussetzung: ADB-Debugging am Fernseher ist eingeschaltet, adb liegt im PATH
# oder wird ueber -Adb angegeben.
param(
    [Parameter(Mandatory = $true)][string]$TvIp,
    [string]$Adb = 'adb',
    [string]$Dns = 'dns.adguard-dns.com',
    [switch]$NoDns
)

$packages = Get-Content (Join-Path $PSScriptRoot 'packages.txt') | Where-Object { $_ -and -not $_.StartsWith('#') }

& $Adb connect "${TvIp}:5555"

# Stand vorher sichern, damit man vergleichen kann
& $Adb shell pm list packages -d | Out-File -Encoding utf8 (Join-Path $PSScriptRoot 'disabled-before.txt')

# Pakete nur fuer den Benutzer deaktivieren (kein Root noetig, kein Loeschen)
foreach ($p in $packages) { & $Adb shell pm disable-user --user 0 $p }

if (-not $NoDns) {
    & $Adb shell settings put global private_dns_mode hostname
    & $Adb shell settings put global private_dns_specifier $Dns
}

& $Adb shell pm list packages -d | Out-File -Encoding utf8 (Join-Path $PSScriptRoot 'disabled-after.txt')

Write-Host 'Fertig. Alternativer Launcher: siehe README (Home on Fire + Projectivy).'
Write-Host 'Bitte den Fernseher einmal neu starten und disabled-after.txt pruefen.'
