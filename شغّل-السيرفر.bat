@echo off
chcp 65001 >nul
title 💡 سيرفر رحلة الابتكار
cd /d "%~dp0"

set PORT=8080
set URL=http://localhost:%PORT%/trainee-presentation.html
set URL_PKG=http://localhost:%PORT%/trainee-package.html
set URL_TR=http://localhost:%PORT%/trainer.html

cls
echo.
echo  ============================================================
echo    سيرفر حقيبة "رحلة الابتكار" — اليوم الأول: العقلية
echo  ============================================================
echo.
echo    عرض المدرّب     : %URL%
echo    ملف المتدرّب    : %URL_PKG%
echo    دليل المدرّب    : %URL_TR%
echo.
echo    لإيقاف السيرفر: اغلق هذه النافذة (أو اضغط Ctrl+C)
echo  ------------------------------------------------------------
echo.

REM ============================================================
REM  محاولة 1: Python (الأسرع والأسهل)
REM ============================================================
where python >nul 2>nul
if %errorlevel%==0 (
    echo  [OK] تم اكتشاف Python — يبدأ السيرفر الآن...
    echo.
    start "" "%URL%"
    python -m http.server %PORT%
    exit /b
)

where py >nul 2>nul
if %errorlevel%==0 (
    echo  [OK] تم اكتشاف Python (py) — يبدأ السيرفر الآن...
    echo.
    start "" "%URL%"
    py -m http.server %PORT%
    exit /b
)

REM ============================================================
REM  محاولة 2: Node.js
REM ============================================================
where node >nul 2>nul
if %errorlevel%==0 (
    echo  [OK] تم اكتشاف Node.js — يبدأ السيرفر الآن...
    echo  [..] قد يستغرق التحميل أول مرة بضع ثوانٍ
    echo.
    start "" "%URL%"
    npx --yes http-server -p %PORT% -c-1
    exit /b
)

REM ============================================================
REM  محاولة 3: PowerShell HttpListener (متاح دائماً على Windows)
REM ============================================================
echo  [OK] استخدام PowerShell كسيرفر (لا يحتاج تثبيت أي شيء)
echo.
start "" "%URL%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ErrorActionPreference='Stop';" ^
"$root = '%~dp0';" ^
"$listener = New-Object System.Net.HttpListener;" ^
"$listener.Prefixes.Add('http://localhost:%PORT%/');" ^
"try { $listener.Start() } catch { Write-Host '  [خطأ] لم يبدأ السيرفر. ربما المنفذ %PORT% مستخدم.' -ForegroundColor Red; pause; exit 1 };" ^
"Write-Host ('  [+] السيرفر يعمل على http://localhost:%PORT%/') -ForegroundColor Green;" ^
"Write-Host '  [i] اضغط Ctrl+C في هذه النافذة لإيقاف السيرفر' -ForegroundColor Yellow;" ^
"Write-Host '';" ^
"$mime = @{ '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8'; '.css'='text/css; charset=utf-8'; '.js'='application/javascript; charset=utf-8'; '.json'='application/json; charset=utf-8'; '.md'='text/markdown; charset=utf-8'; '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.gif'='image/gif'; '.svg'='image/svg+xml'; '.webp'='image/webp'; '.ico'='image/x-icon'; '.woff'='font/woff'; '.woff2'='font/woff2'; '.ttf'='font/ttf'; '.pdf'='application/pdf' };" ^
"while ($listener.IsListening) {" ^
"  try {" ^
"    $ctx = $listener.GetContext();" ^
"    $req = $ctx.Request; $res = $ctx.Response;" ^
"    $path = [System.Web.HttpUtility]::UrlDecode($req.Url.LocalPath).TrimStart('/');" ^
"    if ([string]::IsNullOrEmpty($path)) { $path = 'trainee-presentation.html' };" ^
"    $file = Join-Path $root $path;" ^
"    Write-Host ('  ' + (Get-Date -Format HH:mm:ss) + '  ' + $req.HttpMethod + '  /' + $path) -ForegroundColor Gray;" ^
"    if ((Test-Path $file -PathType Leaf)) {" ^
"      $ext = [System.IO.Path]::GetExtension($file).ToLower();" ^
"      $ct = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' };" ^
"      $bytes = [System.IO.File]::ReadAllBytes($file);" ^
"      $res.ContentType = $ct;" ^
"      $res.ContentLength64 = $bytes.Length;" ^
"      $res.OutputStream.Write($bytes, 0, $bytes.Length);" ^
"    } else {" ^
"      $res.StatusCode = 404;" ^
"      $msg = [Text.Encoding]::UTF8.GetBytes('<h1 style=text-align:center;font-family:sans-serif;color:#dc2626>404 - الملف غير موجود</h1><p style=text-align:center;font-family:monospace>' + $path + '</p>');" ^
"      $res.ContentType = 'text/html; charset=utf-8';" ^
"      $res.OutputStream.Write($msg, 0, $msg.Length);" ^
"    };" ^
"    $res.Close();" ^
"  } catch { Write-Host ('  [warn] ' + $_.Exception.Message) -ForegroundColor DarkYellow }" ^
"}"

exit /b
