param(
    [int]$Port = 8765,
    [switch]$NoBrowser,
    [string]$SqlDb = '',
    [string]$SqlQuery = "SELECT ts,tag_value,status,temp,pressure,vibration FROM live_cache LIMIT 1;",
    [string]$MqttHost = '127.0.0.1',
    [int]$MqttPort = 1883,
    [string]$MqttTopic = 'ancl/edge/#',
    [switch]$MqttTls,
    [string]$MqttUser = '',
    [string]$MqttPassword = '',
    [string]$MqttCaFile = '',
    [switch]$NoGenerator
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$db = if ($SqlDb) { $SqlDb } else { Join-Path $root 'bin\industrial_metrics.db' }
$runtime = Join-Path $root "localtest\dashboard_runtime_$Port"
$mqttState = Join-Path $runtime 'mqtt_latest.json'
$sqlite = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\SQLite.SQLite_Microsoft.Winget.Source_8wekyb3d8bbwe\sqlite3.exe'
$mosquittoPub = 'C:\Program Files\mosquitto\mosquitto_pub.exe'
$mosquittoSub = 'C:\Program Files\mosquitto\mosquitto_sub.exe'
$culture = [Globalization.CultureInfo]::InvariantCulture

foreach ($tool in @($sqlite, $mosquittoPub, $mosquittoSub)) {
    if (-not (Test-Path $tool)) {
        throw "Required tool not found: $tool"
    }
}

New-Item -ItemType Directory -Force $runtime | Out-Null

$svc = Get-Service mosquitto -ErrorAction SilentlyContinue
if (-not $NoGenerator -and $MqttHost -eq '127.0.0.1' -and $svc -and $svc.Status -ne 'Running') {
    Start-Service mosquitto
}

if (-not $NoGenerator) {
    & $sqlite $db "DROP TABLE IF EXISTS live_cache; DROP TABLE IF EXISTS metrics_history; CREATE TABLE live_cache(tag_value TEXT, status TEXT, ts TEXT, temp REAL, pressure REAL, vibration REAL); CREATE TABLE metrics_history(id INTEGER PRIMARY KEY AUTOINCREMENT, ts TEXT, tag_value TEXT, status TEXT, temp REAL, pressure REAL, vibration REAL);"
}

@{
    topic = ''
    payload = 'Waiting for MQTT...'
    ts = ''
} | ConvertTo-Json | Set-Content -Encoding UTF8 $mqttState

$generator = $null
if (-not $NoGenerator) {
$generator = Start-Job -ArgumentList $sqlite, $db, $mosquittoPub, $MqttHost, $MqttPort, $MqttTls.IsPresent, $MqttUser, $MqttPassword, $MqttCaFile -ScriptBlock {
    param($sqlite, $db, $mosquittoPub, $mqttHost, $mqttPort, $mqttTls, $mqttUser, $mqttPassword, $mqttCaFile)
    $culture = [Globalization.CultureInfo]::InvariantCulture
    $i = 0
    while ($true) {
        $i++
        $now = Get-Date
        $ts = $now.ToString('HH:mm:ss')
        $temp = [math]::Round(22.5 + [math]::Sin($i / 5.0) * 4.0 + (Get-Random -Minimum -0.35 -Maximum 0.35), 2)
        $pressure = [math]::Round(1.15 + [math]::Cos($i / 7.0) * 0.18 + (Get-Random -Minimum -0.02 -Maximum 0.02), 3)
        $vibration = [math]::Round(2.0 + [math]::Sin($i / 3.0) * 1.2 + (Get-Random -Minimum -0.12 -Maximum 0.12), 2)
        $tempSql = $temp.ToString('0.00', $culture)
        $pressureSql = $pressure.ToString('0.000', $culture)
        $vibrationSql = $vibration.ToString('0.00', $culture)
        $status = 'ALARM'
        $payload = "TEMP=$tempSql PRESS=$pressureSql VIB=$vibrationSql"
        $sql = "BEGIN; DELETE FROM live_cache; INSERT INTO live_cache VALUES('$payload','$status','$ts',$tempSql,$pressureSql,$vibrationSql); INSERT INTO metrics_history(ts,tag_value,status,temp,pressure,vibration) VALUES('$ts','$payload','$status',$tempSql,$pressureSql,$vibrationSql); DELETE FROM metrics_history WHERE id NOT IN (SELECT id FROM metrics_history ORDER BY id DESC LIMIT 80); COMMIT;"
        & $sqlite $db $sql | Out-Null
        $args = @('-h', $mqttHost, '-p', "$mqttPort", '-t', 'ancl/edge/live', '-m', $payload)
        if ($mqttTls) {
            if ($mqttCaFile) { $args += @('--cafile', $mqttCaFile) } else { $args += @('--tls-use-os-certs') }
        }
        if ($mqttUser) { $args += @('-u', $mqttUser) }
        if ($mqttPassword) { $args += @('-P', $mqttPassword) }
        & $mosquittoPub @args | Out-Null
        Start-Sleep -Milliseconds 1000
    }
}
}

$subscriber = Start-Job -ArgumentList $mosquittoSub, $mqttState, $MqttHost, $MqttPort, $MqttTopic, $MqttTls.IsPresent, $MqttUser, $MqttPassword, $MqttCaFile -ScriptBlock {
    param($mosquittoSub, $mqttState, $mqttHost, $mqttPort, $mqttTopic, $mqttTls, $mqttUser, $mqttPassword, $mqttCaFile)
    $args = @('-h', $mqttHost, '-p', "$mqttPort", '-t', $mqttTopic, '-v')
    if ($mqttTls) {
        if ($mqttCaFile) { $args += @('--cafile', $mqttCaFile) } else { $args += @('--tls-use-os-certs') }
    }
    if ($mqttUser) { $args += @('-u', $mqttUser) }
    if ($mqttPassword) { $args += @('-P', $mqttPassword) }
    & $mosquittoSub @args | ForEach-Object {
        $line = $_
        $space = $line.IndexOf(' ')
        if ($space -gt 0) {
            $topic = $line.Substring(0, $space)
            $payload = $line.Substring($space + 1)
        } else {
            $topic = 'ancl/edge/#'
            $payload = $line
        }
        @{
            topic = $topic
            payload = $payload
            ts = (Get-Date).ToString('HH:mm:ss')
        } | ConvertTo-Json | Set-Content -Encoding UTF8 $mqttState
    }
}

function Invoke-SqlLines {
    param([string]$Sql)
    & $sqlite -batch -separator '|' $db $Sql
}

function Get-StateJson {
    $latest = Invoke-SqlLines $SqlQuery
    $sqlObj = @{
        ts = ''
        tag_value = 'Waiting for SQL...'
        status = ''
        temp = 0
        pressure = 0
        vibration = 0
    }
    if ($latest) {
        $p = ($latest | Select-Object -First 1).Split('|')
        if ($p.Count -ge 6) {
            $sqlObj = @{
                ts = $p[0]
                tag_value = $p[1]
                status = $p[2]
                temp = [double]::Parse($p[3], $culture)
                pressure = [double]::Parse($p[4], $culture)
                vibration = [double]::Parse($p[5], $culture)
            }
        } else {
            $sqlObj = @{
                ts = (Get-Date).ToString('HH:mm:ss')
                tag_value = ($latest | Select-Object -First 1)
                status = 'QUERY'
                temp = 0
                pressure = 0
                vibration = 0
            }
        }
    }

    $historyRows = @()
    if (-not $NoGenerator) {
        $historyRows = @(Invoke-SqlLines "SELECT ts,temp,pressure,vibration FROM metrics_history ORDER BY id DESC LIMIT 40;")
    }
    [array]::Reverse($historyRows)
    $history = @()
    foreach ($row in $historyRows) {
        if (-not $row) { continue }
        $p = $row.Split('|')
        if ($p.Count -ge 4) {
            $history += @{
                ts = $p[0]
                temp = [double]::Parse($p[1], $culture)
                pressure = [double]::Parse($p[2], $culture)
                vibration = [double]::Parse($p[3], $culture)
            }
        }
    }

    $mqttObj = @{
        topic = ''
        payload = 'Waiting for MQTT...'
        ts = ''
    }
    if (Test-Path $mqttState) {
        try {
            $mqttObj = Get-Content $mqttState -Raw | ConvertFrom-Json
        } catch {}
    }

    @{
        generated_at = (Get-Date).ToString('HH:mm:ss')
        sql = $sqlObj
        mqtt = $mqttObj
        history = $history
    } | ConvertTo-Json -Depth 6
}

$html = @'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>ANCL SQL + MQTT Live Dashboard</title>
  <style>
    :root { color-scheme: dark; --bg:#08101c; --panel:#020406; --line:#43657c; --text:#d9e7ff; --muted:#8796ab; --hot:#fb923c; --ok:#39d353; --cyan:#29ffff; }
    * { box-sizing: border-box; }
    body { margin:0; background:var(--bg); color:var(--text); font-family:Consolas, monospace; }
    header { height:48px; display:flex; align-items:center; gap:16px; padding:0 18px; background:var(--panel); border-bottom:2px solid var(--hot); }
    header strong { color:var(--hot); }
    main { padding:20px; display:grid; grid-template-columns: 1fr 1fr; gap:16px; }
    section { border:1px solid var(--line); padding:16px; background:#050b14; min-height:180px; }
    h2 { margin:0 0 14px; color:var(--hot); font-size:16px; }
    .metric { display:grid; grid-template-columns: 130px 1fr; gap:8px; margin:8px 0; }
    .label { color:var(--muted); }
    .value { color:#fff; overflow-wrap:anywhere; }
    .big { font-size:28px; color:var(--ok); }
    canvas { width:100%; height:220px; border:1px solid var(--line); background:#02060d; }
    .wide { grid-column:1 / -1; }
  </style>
</head>
<body>
  <header><strong>ANCL</strong><span>| SQL + MQTT Live Dashboard</span><span id="clock"></span></header>
  <main>
    <section>
      <h2>SQL LIVE CACHE</h2>
      <div class="metric"><div class="label">Timestamp</div><div class="value" id="sql-ts">-</div></div>
      <div class="metric"><div class="label">Status</div><div class="value" id="sql-status">-</div></div>
      <div class="metric"><div class="label">Payload</div><div class="value big" id="sql-payload">-</div></div>
      <div class="metric"><div class="label">Temp</div><div class="value" id="sql-temp">-</div></div>
      <div class="metric"><div class="label">Pressure</div><div class="value" id="sql-pressure">-</div></div>
      <div class="metric"><div class="label">Vibration</div><div class="value" id="sql-vibration">-</div></div>
    </section>
    <section>
      <h2>MQTT LAST MESSAGE</h2>
      <div class="metric"><div class="label">Timestamp</div><div class="value" id="mqtt-ts">-</div></div>
      <div class="metric"><div class="label">Topic</div><div class="value" id="mqtt-topic">-</div></div>
      <div class="metric"><div class="label">Payload</div><div class="value big" id="mqtt-payload">-</div></div>
    </section>
    <section class="wide">
      <h2>SQL HISTORY</h2>
      <canvas id="chart" width="1200" height="260"></canvas>
    </section>
  </main>
  <script>
    const el = id => document.getElementById(id);
    function draw(history) {
      const c = el('chart'), ctx = c.getContext('2d');
      ctx.clearRect(0,0,c.width,c.height);
      ctx.strokeStyle = '#43657c';
      ctx.lineWidth = 1;
      for (let y=30; y<c.height; y+=40) { ctx.beginPath(); ctx.moveTo(0,y); ctx.lineTo(c.width,y); ctx.stroke(); }
      const series = [
        ['temp', '#fb923c', 15, 30],
        ['pressure', '#29ffff', 0.8, 1.5],
        ['vibration', '#39d353', 0, 4]
      ];
      for (const [key, color, min, max] of series) {
        ctx.strokeStyle = color; ctx.lineWidth = 3; ctx.beginPath();
        history.forEach((p, i) => {
          const x = history.length <= 1 ? 0 : i * (c.width - 20) / (history.length - 1) + 10;
          const v = Math.max(min, Math.min(max, Number(p[key])));
          const y = c.height - 18 - ((v - min) / (max - min)) * (c.height - 36);
          if (i === 0) ctx.moveTo(x,y); else ctx.lineTo(x,y);
        });
        ctx.stroke();
      }
      ctx.fillStyle = '#8796ab';
      ctx.fillText('temp orange | pressure cyan | vibration green', 14, 20);
    }
    async function tick() {
      const r = await fetch('/api/state', { cache: 'no-store' });
      const s = await r.json();
      el('clock').textContent = s.generated_at;
      el('sql-ts').textContent = s.sql.ts;
      el('sql-status').textContent = s.sql.status;
      el('sql-payload').textContent = s.sql.tag_value;
      el('sql-temp').textContent = s.sql.temp;
      el('sql-pressure').textContent = s.sql.pressure;
      el('sql-vibration').textContent = s.sql.vibration;
      el('mqtt-ts').textContent = s.mqtt.ts || '-';
      el('mqtt-topic').textContent = s.mqtt.topic || '-';
      el('mqtt-payload').textContent = s.mqtt.payload || '-';
      draw(s.history || []);
    }
    setInterval(tick, 1000); tick();
  </script>
</body>
</html>
'@

$listener = [System.Net.HttpListener]::new()
$prefix = "http://127.0.0.1:$Port/"
$listener.Prefixes.Add($prefix)
$listener.Start()

if (-not $NoBrowser) {
    Start-Process $prefix
}

Write-Host "Live dashboard running at $prefix"
Write-Host "Keep this PowerShell window open. Press Ctrl+C to stop."

try {
    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        $path = $ctx.Request.Url.AbsolutePath
        if ($path -eq '/api/state') {
            $body = Get-StateJson
            $ctx.Response.ContentType = 'application/json'
        } else {
            $body = $html
            $ctx.Response.ContentType = 'text/html; charset=utf-8'
        }
        $bytes = [Text.Encoding]::UTF8.GetBytes($body)
        $ctx.Response.ContentLength64 = $bytes.Length
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        $ctx.Response.OutputStream.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
    if ($generator) { Stop-Job $generator -ErrorAction SilentlyContinue | Out-Null; Remove-Job $generator -Force -ErrorAction SilentlyContinue | Out-Null }
    Stop-Job $subscriber -ErrorAction SilentlyContinue | Out-Null
    Remove-Job $subscriber -Force -ErrorAction SilentlyContinue | Out-Null
}
