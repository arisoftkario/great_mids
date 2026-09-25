@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set PORT=8080

:find_available_port
netstat -ano | findstr /c:":%PORT% " | findstr /i "LISTENING" >nul
if errorlevel 1 goto start_site

set /a PORT+=1
if %PORT% LEQ 8090 goto find_available_port

echo Aucun port libre entre 8080 et 8090.
pause
exit /b 1

:start_site
start "GREAT MINDS GROUP - Serveur local" /min cmd /c "flutter run -d web-server --web-hostname localhost --web-port %PORT%"
set /a ATTEMPTS=0

:wait_for_site
timeout /t 1 /nobreak >nul
netstat -ano | findstr /c:":%PORT% " | findstr /i "LISTENING" >nul
if not errorlevel 1 (
  start "" "http://localhost:%PORT%"
  exit /b 0
)

set /a ATTEMPTS+=1
if !ATTEMPTS! LSS 30 goto wait_for_site

echo Le site n'a pas pu demarrer. Verifiez que Flutter est installe puis reessayez.
pause
exit /b 1
