$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$exe = Join-Path $root 'bin\sql_to_mqtt.exe'

if (-not (Test-Path $exe)) {
    throw "sql_to_mqtt.exe was not found at $exe"
}

Start-Process -FilePath $exe -WorkingDirectory (Join-Path $root 'bin')
