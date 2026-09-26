@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

echo ========================================================
echo   DEPLOIEMENT FLUTTER WEB SUR GITHUB PAGES (gh-pages)
echo ========================================================
echo.

echo [1/4] Compilation du site Flutter Web...
call flutter build web --release --base-href "/great_minds/"
if errorlevel 1 (
    echo Erreur lors du build Flutter.
    pause
    exit /b 1
)

echo.
echo [2/4] Preparation des fichiers pour GitHub Pages (.nojekyll et 404.html)...
copy /Y "build\web\index.html" "build\web\404.html" >nul
type nul > "build\web\.nojekyll"

echo.
echo [3/4] Publication sur la branche gh-pages de GitHub...
cd build\web
if exist ".git" (
    rmdir /s /q ".git"
)
git init -b gh-pages
git add .
git commit -m "Deploy site web to GitHub Pages"
git remote add origin https://github.com/arisoftkario/great_minds.git
git push -f origin gh-pages

cd /d "%~dp0"

echo.
echo ========================================================
echo   SUCCES ! VOTRE SITE EST DEPLOYE SUR GITHUB PAGES
echo ========================================================
echo.
echo Votre site sera en ligne dans quelques secondes a l'adresse :
echo   https://arisoftkario.github.io/great_minds/
echo.
echo ========================================================
pause
