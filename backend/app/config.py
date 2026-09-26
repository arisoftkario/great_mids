import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Great Minds Group API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Sécurité & JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "great_minds_super_secret_jwt_key_change_in_production_2026")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 heures pour dev / 15-60 min en prod
    
    # Base de données (SQLite par défaut en dev, modifiable vers PostgreSQL en prod)
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./great_minds.db")
    
    # CORS (Origines autorisées pour Flutter Web)
    ALLOWED_ORIGINS: list[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "https://arisoftkario.github.io",
    ]

    class Config:
        case_sensitive = True

settings = Settings()
