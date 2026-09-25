@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

echo ========================================================
echo   LANCEMENT DU SERVEUR FLUTTER POUR TEST SUR MOBILE
echo ========================================================
echo.

:: Trouver l'IP locale de la machine
set IP=
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4" ^| findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"') do (
    if not defined IP (
        set IP=%%a
        set IP=!IP: =!
    )
)

if not defined IP (
    set IP=localhost
)

set PORT=8080

echo [1] Connectez votre telephone sur le MEME reseau Wi-Fi / partage de connexion que ce PC.
echo [2] Votre adresse IP locale est : %IP%
echo [3] Une fois le serveur pret, ouvrez Chrome/Safari sur votre telephone et tapez :
echo.
echo      http://%IP%:%PORT%
echo.
echo ========================================================
echo Lancement du serveur Flutter...
echo Appuyez sur 'r' dans la fenetre pour Hot Reload ou 'R' pour Hot Restart.
echo ========================================================
echo.

flutter run -d web-server --web-hostname 0.0.0.0 --web-port %PORT%

pause
