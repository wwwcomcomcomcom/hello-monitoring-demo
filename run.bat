@echo off
REM Render prometheus.yml from template with environment variables or CLI args, then docker compose up
setlocal

REM Default and CLI override for SCRAPE_TARGET only
if "%SCRAPE_TARGET%"=="" set SCRAPE_TARGET=host.docker.internal:8080
if not "%~1"=="" set SCRAPE_TARGET=%~1

echo Rendering prometheus.yml with:
echo   SCRAPE_TARGET=%SCRAPE_TARGET%

set TEMPLATE=prometheus.yml.tmpl
set OUT=prometheus.yml

REM Use PowerShell for robust token replacement
powershell -NoProfile -Command ^
  "$t = Get-Content -Raw '%TEMPLATE%'; ^
   $t = $t -replace '\$\{SCRAPE_TARGET\}', '%SCRAPE_TARGET%'; ^
   Set-Content -NoNewline -Path '%OUT%' -Value $t"

if errorlevel 1 (
  echo Failed to render %OUT%
  exit /b 1
)

echo prometheus.yml rendered. Starting docker compose...
docker compose up --build -d
if errorlevel 1 (
  echo docker compose failed
  exit /b 1
)

echo Done. Use "docker compose ps" to see status.
endlocal
