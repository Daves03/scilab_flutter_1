param(
    [ValidateSet('debug', 'profile', 'release')]
    [string]$Mode = 'release'
)

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$configPath = Join-Path $projectRoot '.gemini.local.json'

if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw "Missing $configPath. Create it with GEMINI_API_KEY and GEMINI_MODEL values."
}

$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace([string]$config.GEMINI_API_KEY)) {
    throw 'GEMINI_API_KEY is missing or empty in .gemini.local.json.'
}

Push-Location $projectRoot
try {
    & flutter build apk "--$Mode" "--dart-define-from-file=$configPath"
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter APK build failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}
