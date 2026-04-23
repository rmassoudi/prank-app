param(
    [string]$OutputDirectory = "$PSScriptRoot\..\MadeYouLookPrank\Assets.xcassets\AppIcon.appiconset"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

function Add-FlamePath {
    param(
        [System.Drawing.Drawing2D.GraphicsPath]$Path,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H
    )

    function P([float]$px, [float]$py) {
        New-Object System.Drawing.PointF (($X + $W * $px), ($Y + $H * $py))
    }

    $Path.StartFigure()
    $Path.AddBezier((P 0.50 0.95), (P 0.35 0.88), (P 0.24 0.80), (P 0.27 0.68))
    $Path.AddBezier((P 0.27 0.68), (P 0.29 0.55), (P 0.39 0.47), (P 0.39 0.37))
    $Path.AddBezier((P 0.39 0.37), (P 0.39 0.25), (P 0.48 0.15), (P 0.47 0.07))
    $Path.AddBezier((P 0.47 0.07), (P 0.67 0.20), (P 0.76 0.34), (P 0.73 0.49))
    $Path.AddBezier((P 0.73 0.49), (P 0.81 0.46), (P 0.87 0.40), (P 0.90 0.35))
    $Path.AddBezier((P 0.90 0.35), (P 1.00 0.66), (P 0.82 0.90), (P 0.50 0.95))
    $Path.CloseFigure()
}

function Add-InnerFlamePath {
    param(
        [System.Drawing.Drawing2D.GraphicsPath]$Path,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H
    )

    function P([float]$px, [float]$py) {
        New-Object System.Drawing.PointF (($X + $W * $px), ($Y + $H * $py))
    }

    $Path.StartFigure()
    $Path.AddBezier((P 0.50 0.92), (P 0.38 0.82), (P 0.31 0.73), (P 0.32 0.62))
    $Path.AddBezier((P 0.32 0.62), (P 0.34 0.45), (P 0.48 0.36), (P 0.46 0.21))
    $Path.AddBezier((P 0.46 0.21), (P 0.64 0.38), (P 0.73 0.48), (P 0.71 0.62))
    $Path.AddBezier((P 0.71 0.62), (P 0.69 0.78), (P 0.62 0.87), (P 0.50 0.92))
    $Path.CloseFigure()
}

function New-AppIcon {
    param(
        [string]$Path,
        [int]$Size
    )

    $bitmap = New-Object System.Drawing.Bitmap $Size, $Size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::White)

    $margin = [float]($Size * 0.18)
    $flameSize = [float]($Size - ($margin * 2))
    $rect = New-Object System.Drawing.RectangleF $margin, $margin, $flameSize, $flameSize

    $mainPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    Add-FlamePath -Path $mainPath -X $rect.X -Y $rect.Y -W $rect.Width -H $rect.Height

    $mainBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush -ArgumentList @(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 255, 120, 44),
        [System.Drawing.Color]::FromArgb(255, 205, 12, 62),
        [single]45
    )
    $graphics.FillPath($mainBrush, $mainPath)

    $innerMargin = [float]($Size * 0.34)
    $innerSize = [float]($Size - ($innerMargin * 2))
    $innerRect = New-Object System.Drawing.RectangleF $innerMargin, ($innerMargin + ($Size * 0.08)), $innerSize, $innerSize
    $innerPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    Add-InnerFlamePath -Path $innerPath -X $innerRect.X -Y $innerRect.Y -W $innerRect.Width -H $innerRect.Height
    $innerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush -ArgumentList @(
        $innerRect,
        [System.Drawing.Color]::FromArgb(255, 255, 229, 88),
        [System.Drawing.Color]::FromArgb(255, 255, 113, 36),
        [single]90
    )
    $graphics.FillPath($innerBrush, $innerPath)

    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

    $innerBrush.Dispose()
    $innerPath.Dispose()
    $mainBrush.Dispose()
    $mainPath.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

$icons = @(
    @{ Name = "Icon-20x20@2x.png"; Size = 40 },
    @{ Name = "Icon-20x20@3x.png"; Size = 60 },
    @{ Name = "Icon-29x29@2x.png"; Size = 58 },
    @{ Name = "Icon-29x29@3x.png"; Size = 87 },
    @{ Name = "Icon-40x40@2x.png"; Size = 80 },
    @{ Name = "Icon-40x40@3x.png"; Size = 120 },
    @{ Name = "Icon-60x60@2x.png"; Size = 120 },
    @{ Name = "Icon-60x60@3x.png"; Size = 180 },
    @{ Name = "Icon-iPad-20x20@1x.png"; Size = 20 },
    @{ Name = "Icon-iPad-20x20@2x.png"; Size = 40 },
    @{ Name = "Icon-iPad-29x29@1x.png"; Size = 29 },
    @{ Name = "Icon-iPad-29x29@2x.png"; Size = 58 },
    @{ Name = "Icon-iPad-40x40@1x.png"; Size = 40 },
    @{ Name = "Icon-iPad-40x40@2x.png"; Size = 80 },
    @{ Name = "Icon-iPad-76x76@1x.png"; Size = 76 },
    @{ Name = "Icon-iPad-76x76@2x.png"; Size = 152 },
    @{ Name = "Icon-iPad-83.5x83.5@2x.png"; Size = 167 },
    @{ Name = "Icon-1024x1024@1x.png"; Size = 1024 }
)

foreach ($icon in $icons) {
    New-AppIcon -Path (Join-Path $OutputDirectory $icon.Name) -Size $icon.Size
}

Write-Host "Generated $($icons.Count) app icons in $OutputDirectory"
