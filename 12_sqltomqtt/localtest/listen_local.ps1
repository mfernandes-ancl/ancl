$ErrorActionPreference = 'Stop'

$mosquittoSub = 'C:\Program Files\mosquitto\mosquitto_sub.exe'
if (-not (Test-Path $mosquittoSub)) {
    throw "mosquitto_sub.exe was not found at $mosquittoSub"
}

& $mosquittoSub -h 127.0.0.1 -p 1883 -t ancl/edge/telemetry -v
