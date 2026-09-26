@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

echo ========================================================
echo   DEPLOIEMENT FLUTTER WEB SUR GITHUB PAGES
echo   DOMAINE: www.greatmindsgroupe.com
echo ========================================================
echo.

:: Recuperer l'URL du remote git actuel
for /f "tokens=*" %%a in ('git remote get-url origin') do set REMOTE_URL=%%a

echo [1/4] Compilation du site Flutter Web pour domaine personnalise...
call flutter build web --release --base-href "/"
if errorlevel 1 (
    echo Erreur lors du build Flutter.
    pause
    exit /b 1
)

echo.
echo [2/4] Preparation des fichiers pour GitHub Pages (.nojekyll, 404.html, CNAME)...
copy /Y "build\web\index.html" "build\web\404.html" >nul
type nul > "build\web\.nojekyll"
copy /Y "web\CNAME" "build\web\CNAME" >nul

echo.
echo [3/4] Publication sur la branche gh-pages de GitHub (%REMOTE_URL%)...
cd build\web
if exist ".git" (
    rmdir /s /q ".git"
)
git init -b gh-pages
git add .
git commit -m "Deploy site web to www.greatmindsgroupe.com"
git remote add origin %REMOTE_URL%
git push -f origin gh-pages

cd /d "%~dp0"

echo.
echo ========================================================
echo   SUCCES ! VOTRE SITE EST EN LIGNE
echo ========================================================
echo.
echo Votre site sera accessible sur :
echo   https://www.greatmindsgroupe.com
echo.
echo ========================================================
pause
