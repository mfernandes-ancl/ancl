# verify_selfhost.ps1 - prove ANCL self-hosts, from THIS bundle (no repo layout assumed).
# Place: ships in the bundle's src/ folder. Run it from anywhere:
#     powershell -ExecutionPolicy Bypass -File src\verify_selfhost.ps1
#
# It uses the shipped compiler (../anclc.exe) to build the ANCL-written compiler from the
# pre-generated single-file source (anclc2_all.ancl), then has THAT compiler compile its own
# source twice and checks the two results are byte-identical (the self-host fixpoint).
$ErrorActionPreference = 'Stop'
$src   = $PSScriptRoot                                   # ...\src
$anclc = Join-Path (Split-Path $src -Parent) 'anclc.exe' # bundle-root anclc.exe
$all   = Join-Path $src 'anclc2_all.ancl'
if (-not (Test-Path $anclc)) { Write-Host "anclc.exe not found next to this bundle" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $all))   { Write-Host "anclc2_all.ancl missing from src\" -ForegroundColor Red; exit 1 }

Push-Location $src
try {
    Write-Host "[1/3] bootstrap: shipped anclc builds the ANCL-written compiler..." -ForegroundColor Cyan
    & $anclc $all stage2.exe   | Out-Null
    Write-Host "[2/3] self-compile: that compiler compiles its own source..." -ForegroundColor Cyan
    & (Join-Path $src 'stage2.exe') $all anclc3.exe | Out-Null
    Write-Host "[3/3] fixpoint: it compiles itself again - the two must match..." -ForegroundColor Cyan
    & (Join-Path $src 'anclc3.exe') $all anclc4.exe | Out-Null

    $h3 = (Get-FileHash anclc3.exe -Algorithm SHA256).Hash
    $h4 = (Get-FileHash anclc4.exe -Algorithm SHA256).Hash
    if ($h3 -eq $h4) {
        Write-Host ("PASS - ANCL self-hosts: anclc3 == anclc4 (SHA-256 {0})" -f $h3.Substring(0,16)) -ForegroundColor Green
        $rc = 0
    } else {
        Write-Host "FAIL - anclc3 and anclc4 differ" -ForegroundColor Red
        $rc = 1
    }
    Remove-Item stage2.exe,anclc3.exe,anclc4.exe,*.asm -ErrorAction SilentlyContinue
    exit $rc
} finally { Pop-Location }
