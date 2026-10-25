# Generates placeholder JPG images for the portfolio (profile + 3 project thumbnails)
# Run from the project root:  powershell -ExecutionPolicy Bypass -File tools\generate-images.ps1

Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot "..\images"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

function New-GradientBitmap {
    param(
        [int]$width,
        [int]$height,
        [System.Drawing.Color]$colorA,
        [System.Drawing.Color]$colorB,
        [double]$angleDegrees
    )
    $bmp = [System.Drawing.Bitmap]::new($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $rect = [System.Drawing.Rectangle]::new(0, 0, $width, $height)
    $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect, $colorA, $colorB, [float]($angleDegrees * [Math]::PI / 180.0))
    $g.FillRectangle($brush, $rect)
    return @{ Graphics = $g; Bitmap = $bmp }
}

function Add-SoftCircle {
    param($g, [float]$cx, [float]$cy, [float]$radius, [System.Drawing.Color]$color)
    $b = [System.Drawing.SolidBrush]::new($color)
    $g.FillEllipse($b, ($cx - $radius), ($cy - $radius), ($radius * 2), ($radius * 2))
    $b.Dispose()
}

function Add-RoundedPanel {
    param($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$radius, [System.Drawing.Color]$color)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $radius * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
    $path.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
    $path.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
    $path.CloseFigure()
    $b = [System.Drawing.SolidBrush]::new($color)
    $g.FillPath($b, $path)
    $b.Dispose(); $path.Dispose()
}

function Add-Text {
    param($g, [string]$text, [float]$x, [float]$y, [float]$size,
          [System.Drawing.Color]$color, [string]$fontFamily = "Segoe UI")
    $font = [System.Drawing.Font]::new($fontFamily, $size,
        [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
    $sf = [System.Drawing.StringFormat]::new()
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $b = [System.Drawing.SolidBrush]::new($color)
    $point = [System.Drawing.PointF]::new($x, $y)
    $g.DrawString($text, $font, $b, $point, $sf)
    $b.Dispose(); $font.Dispose(); $sf.Dispose()
}

function Save-Jpg {
    param($bmp, [string]$path)
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
             Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ep = [System.Drawing.Imaging.EncoderParameters]::new(1)
    $ep.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new(
        [System.Drawing.Imaging.Encoder]::Quality, [long]88)
    $bmp.Save($path, $codec, $ep)
}

$pinkLight  = [System.Drawing.Color]::FromArgb(255, 246, 214, 231)
$pinkMid    = [System.Drawing.Color]::FromArgb(255, 238, 168, 198)
$lilacLight = [System.Drawing.Color]::FromArgb(255, 214, 196, 240)
$lilacMid   = [System.Drawing.Color]::FromArgb(255, 179, 154, 228)
$white      = [System.Drawing.Color]::FromArgb(235, 255, 255, 255)
$whiteSolid = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$plum       = [System.Drawing.Color]::FromArgb(255, 90, 72, 110)
$plumSoft   = [System.Drawing.Color]::FromArgb(255, 120, 100, 145)
$lilacTint  = [System.Drawing.Color]::FromArgb(255, 226, 208, 240)
$lilacTint2 = [System.Drawing.Color]::FromArgb(255, 228, 212, 242)
$pinkTint   = [System.Drawing.Color]::FromArgb(255, 250, 236, 245)
$pinkTint2  = [System.Drawing.Color]::FromArgb(255, 243, 220, 240)
$sunYellow  = [System.Drawing.Color]::FromArgb(255, 247, 196, 108)
$pinkButton = [System.Drawing.Color]::FromArgb(255, 238, 168, 198)
$pinkCircle = [System.Drawing.Color]::FromArgb(255, 247, 205, 225)
$softWhite  = [System.Drawing.Color]::FromArgb(70, 255, 255, 255)

# ---------- profile.jpg : soft gradient + LM monogram ----------
$c = New-GradientBitmap 900 900 $pinkLight $lilacLight 45
$g = $c.Graphics
Add-SoftCircle $g 720 180 190 $white
Add-SoftCircle $g 150 760 220 $white
Add-SoftCircle $g 450 450 250 $softWhite
Add-Text $g "LM" 450 420 200 $plum "Georgia"
Add-Text $g "Frontend Developer" 450 620 44 $plumSoft
Save-Jpg $c.Bitmap (Join-Path $outDir "profile.jpg")
$g.Dispose(); $c.Bitmap.Dispose()

# ---------- project1.jpg : Weather Vision ----------
$c = New-GradientBitmap 1000 650 $pinkLight $lilacLight 30
$g = $c.Graphics
Add-SoftCircle $g 870 120 130 $white
Add-SoftCircle $g 90 560 160 $white
Add-RoundedPanel $g 140 110 720 430 26 $whiteSolid
Add-SoftCircle $g 260 250 52 $sunYellow
Add-RoundedPanel $g 350 215 300 26 13 $lilacTint
Add-RoundedPanel $g 350 258 210 18 9 $lilacTint2
for ($i = 0; $i -lt 4; $i++) {
    Add-RoundedPanel $g (190 + $i * 160) 360 130 110 16 $pinkTint
}
Add-Text $g "Weather Vision" 500 580 44 $plum
Save-Jpg $c.Bitmap (Join-Path $outDir "project1.jpg")
$g.Dispose(); $c.Bitmap.Dispose()

# ---------- project2.jpg : TaskFlow ----------
$c = New-GradientBitmap 1000 650 $lilacLight $pinkLight 210
$g = $c.Graphics
Add-SoftCircle $g 120 120 140 $white
Add-SoftCircle $g 880 540 150 $white
Add-RoundedPanel $g 220 80 560 450 26 $whiteSolid
for ($i = 0; $i -lt 4; $i++) {
    $y = 130 + $i * 92
    Add-RoundedPanel $g 270 $y 44 44 12 $pinkTint2
    Add-RoundedPanel $g 340 ($y + 12) 340 20 10 $lilacTint2
}
Add-Text $g "TaskFlow - To-Do App" 500 580 42 $plum
Save-Jpg $c.Bitmap (Join-Path $outDir "project2.jpg")
$g.Dispose(); $c.Bitmap.Dispose()

# ---------- project3.jpg : Bloom Bakery ----------
$c = New-GradientBitmap 1000 650 $pinkMid $lilacMid 60
$g = $c.Graphics
Add-SoftCircle $g 850 140 150 $white
Add-SoftCircle $g 130 520 170 $white
Add-RoundedPanel $g 160 100 680 150 22 $whiteSolid
Add-RoundedPanel $g 200 140 380 26 13 $lilacTint
Add-RoundedPanel $g 200 183 260 18 9 $pinkTint
Add-RoundedPanel $g 600 150 200 52 26 $pinkButton
for ($i = 0; $i -lt 3; $i++) {
    Add-RoundedPanel $g (180 + $i * 220) 290 190 170 20 $whiteSolid
    Add-SoftCircle $g (275 + $i * 220) 355 40 $pinkCircle
    Add-RoundedPanel $g (215 + $i * 220) 410 120 16 8 $lilacTint
}
Add-Text $g "Bloom Bakery - Landing Page" 500 545 40 $plum
Save-Jpg $c.Bitmap (Join-Path $outDir "project3.jpg")
$g.Dispose(); $c.Bitmap.Dispose()

Write-Host "Done - images generated in $outDir"
