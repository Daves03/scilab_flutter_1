param(
    [string]$AarPath = (Join-Path $PSScriptRoot '..\android\unityLibrary\libs\unityandroidpermissions.aar')
)

$resolvedAar = [System.IO.Path]::GetFullPath($AarPath)
if (-not (Test-Path -LiteralPath $resolvedAar)) {
    throw "Unity permissions AAR not found: $resolvedAar"
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$oldNamespace = 'package="com.google.ar.core"'
$newNamespace = 'package="com.unity3d.player.androidpermissions"'
$temporaryAar = "$resolvedAar.namespace-fix.tmp"
if (Test-Path -LiteralPath $temporaryAar) {
    Remove-Item -LiteralPath $temporaryAar -Force
}

$source = $null
$destination = $null
try {
    $source = [System.IO.Compression.ZipFile]::OpenRead($resolvedAar)
    $sourceManifest = $source.GetEntry('AndroidManifest.xml')
    if ($null -eq $sourceManifest) {
        throw "AndroidManifest.xml not found in $resolvedAar"
    }

    $reader = [System.IO.StreamReader]::new($sourceManifest.Open())
    try {
        $manifest = $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
    }

    if ($manifest.Contains($newNamespace)) {
        $updatedManifest = $manifest
    }
    elseif ($manifest.Contains($oldNamespace)) {
        $updatedManifest = $manifest.Replace($oldNamespace, $newNamespace)
    }
    else {
        throw 'The permissions AAR has an unexpected manifest namespace; no change was made.'
    }

    $destination = [System.IO.Compression.ZipFile]::Open(
        $temporaryAar,
        [System.IO.Compression.ZipArchiveMode]::Create
    )

    foreach ($entry in $source.Entries) {
        if ($entry.FullName -eq 'AndroidManifest.xml') {
            continue
        }

        $copiedEntry = $destination.CreateEntry($entry.FullName, [System.IO.Compression.CompressionLevel]::Optimal)
        $inputStream = $entry.Open()
        $outputStream = $copiedEntry.Open()
        try {
            $inputStream.CopyTo($outputStream)
        }
        finally {
            $outputStream.Dispose()
            $inputStream.Dispose()
        }
    }

    $replacement = $destination.CreateEntry('AndroidManifest.xml', [System.IO.Compression.CompressionLevel]::Optimal)
    $utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)
    $writer = [System.IO.StreamWriter]::new($replacement.Open(), $utf8WithoutBom)
    try {
        $writer.Write($updatedManifest)
    }
    finally {
        $writer.Dispose()
    }
}
finally {
    if ($null -ne $destination) {
        $destination.Dispose()
    }
    if ($null -ne $source) {
        $source.Dispose()
    }
}

Move-Item -LiteralPath $temporaryAar -Destination $resolvedAar -Force
Write-Output "Updated Unity Android permissions namespace in $resolvedAar"
