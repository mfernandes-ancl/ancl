$ErrorActionPreference = 'Stop'

$sqlite = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\SQLite.SQLite_Microsoft.Winget.Source_8wekyb3d8bbwe\sqlite3.exe'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$db = Join-Path $root 'bin\industrial_metrics.db'

if (-not (Test-Path $sqlite)) {
    throw "sqlite3.exe was not found at $sqlite"
}

& $sqlite $db "DROP TABLE IF EXISTS live_cache; DROP TABLE IF EXISTS metrics_history; CREATE TABLE live_cache(tag_value TEXT, status TEXT, ts TEXT, temp REAL, pressure REAL, vibration REAL); CREATE TABLE metrics_history(id INTEGER PRIMARY KEY AUTOINCREMENT, ts TEXT, tag_value TEXT, status TEXT, temp REAL, pressure REAL, vibration REAL); INSERT INTO live_cache VALUES('LOCAL_TEST_OK','ALARM',datetime('now'),0,0,0); INSERT INTO metrics_history(ts,tag_value,status,temp,pressure,vibration) VALUES(datetime('now'),'LOCAL_TEST_OK','ALARM',0,0,0);"
& $sqlite $db "SELECT rowid, tag_value, status, ts FROM live_cache;"
