param(
    [ValidateSet('debug', 'profile', 'release')]
    [string]$Mode = 'debug'
)

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$configPath = Join-Path $projectRoot '.gemini.local.json'

if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw "Missing $configPath. Create it with GEMINI_API_KEY and GEMINI_MODEL values."
}

try {
    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
}
catch {
    throw "Could not parse $configPath as JSON: $($_.Exception.Message)"
}

if ([string]::IsNullOrWhiteSpace([string]$config.GEMINI_API_KEY)) {
    throw 'GEMINI_API_KEY is missing or empty in .gemini.local.json.'
}

if ([string]::IsNullOrWhiteSpace([string]$config.GEMINI_MODEL)) {
    throw 'GEMINI_MODEL is missing or empty in .gemini.local.json.'
}

Write-Host "Starting SciLab on Chrome with Gemini model $($config.GEMINI_MODEL)."
Write-Host 'The API key was found and will not be printed.'

Push-Location $projectRoot
try {
    & flutter run -d chrome "--$Mode" "--dart-define-from-file=$configPath"
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter Chrome run failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}
