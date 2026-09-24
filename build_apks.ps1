$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$apps = @('partner_app', 'referee_app')

Write-Host 'Building Flutter APKs...' -ForegroundColor Cyan

foreach ($app in $apps) {
    $appPath = Join-Path $repoRoot "apps\$app"

    if (-not (Test-Path (Join-Path $appPath 'pubspec.yaml'))) {
        throw "Flutter app not found: $appPath"
    }

    Write-Host "`n[$app] flutter build apk" -ForegroundColor Yellow
    Push-Location $appPath
    try {
        flutter build apk
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter APK build failed for $app (exit code $LASTEXITCODE)."
        }
    }
    finally {
        Pop-Location
    }

    Write-Host "[$app] APK build completed." -ForegroundColor Green
}

Write-Host "`nBoth APK builds completed successfully." -ForegroundColor Green
