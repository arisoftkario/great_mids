@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   LANCEMENT DU SERVEUR BACKEND FASTAPI - GREAT MINDS
echo ========================================================
echo.

if not exist ".venv" (
    echo [1/2] Creation de l'environnement virtuel...
    py -m venv .venv
    echo [2/2] Installation des dependances...
    .venv\Scripts\pip install -r requirements.txt
)

echo Demarrage du serveur FastAPI sur http://127.0.0.1:8000 ...
echo Documentation Swagger interactive disponible sur : http://127.0.0.1:8000/docs
echo.
.venv\Scripts\uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause
