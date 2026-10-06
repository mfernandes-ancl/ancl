param(
    [Parameter(Mandatory=$true)][string]$Compiler,
    [string]$BuildDirectory = (Join-Path ([System.IO.Path]::GetTempPath()) ('ancl-validation-' + [guid]::NewGuid()))
)
$ErrorActionPreference = 'Stop'
$Compiler = (Resolve-Path -LiteralPath $Compiler).Path
$bundle = Split-Path $PSScriptRoot -Parent
New-Item -ItemType Directory -Path $BuildDirectory -Force | Out-Null
$BuildDirectory = (Resolve-Path -LiteralPath $BuildDirectory).Path
$tests = Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'test_*.ancl' | Where-Object { $_.BaseName -notin @('test_helper', 'test_http') }
$examples = Get-ChildItem -LiteralPath (Join-Path $bundle 'examples') -Filter '*.ancl' | Where-Object { $_.BaseName -ne 'selfheal' }
Push-Location $BuildDirectory
try {
    foreach ($source in @($tests) + @($examples)) {
        $output = Join-Path $BuildDirectory ($source.BaseName + '.exe')
        & $Compiler $source.FullName $output
        if ($LASTEXITCODE -ne 0) { throw "Compilation failed: $($source.Name)" }
        & $output
        if ($LASTEXITCODE -ne 0) { throw "Execution failed: $($source.Name), exit $LASTEXITCODE" }
    }
    $source = Join-Path $bundle 'src/anclc2_all.ancl'
    $previous = $Compiler
    $hashes = @()
    foreach ($generation in 2..4) {
        $output = Join-Path $BuildDirectory "stage$generation.exe"
        & $previous $source $output
        if ($LASTEXITCODE -ne 0) { throw "Self-host generation $generation failed" }
        $hashes += (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
        $previous = $output
    }
    if ($hashes[1] -ne $hashes[2]) { throw 'Self-host fixpoint differs' }
    Write-Host "PASS: all core/examples and self-host fixpoint $($hashes[2])"
    Write-Host "Validation artifacts: $BuildDirectory"
} finally { Pop-Location }
