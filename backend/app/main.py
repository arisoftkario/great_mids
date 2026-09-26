from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine, Base, SessionLocal
from app.models.user import User, UserRole, UserStatus
from app.models.content import ContentItem
from app.core.security import get_password_hash
from app.routers import auth_router, users_router, contents_router, stats_router, public_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Création des tables
    Base.metadata.create_all(bind=engine)
    
    # Création automatique du compte Super Administrateur par défaut si aucun utilisateur n'existe
    db = SessionLocal()
    try:
        admin_count = db.query(User).count()
        if admin_count == 0:
            default_admin = User(
                email="admin@greatminds.com",
                hashed_password=get_password_hash("Admin@GM2026!"),
                full_name="Super Administrateur",
                role=UserRole.SUPER_ADMIN,
                status=UserStatus.ACTIVE,
            )
            db.add(default_admin)
            
            # Ajouter quelques contenus initiaux (Offres exemples)
            sample_offer = ContentItem(
                category="offers",
                title="Conseiller en Insertion Professionnelle",
                slug="conseiller-insertion-professionnelle",
                summary="Accompagnement des jeunes vers l'emploi et coaching personnalisé.",
                details={"type": "CDI", "location": "Kinshasa / Hybride", "department": "Insertion"},
                is_published=True,
            )
            db.add(sample_offer)
            
            db.commit()
            print("✓ Base initialisée avec le Super Admin (admin@greatminds.com / Admin@GM2026!)")
    finally:
        db.close()
    
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API Back-Office et Plateforme pour Great Minds Group",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# Configuration CORS pour autoriser les requêtes depuis Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS + ["*"], # Permettre toutes les origines en dev
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Enregistrement des routes
app.include_router(auth_router, prefix=settings.API_V1_STR)
app.include_router(users_router, prefix=settings.API_V1_STR)
app.include_router(contents_router, prefix=settings.API_V1_STR)
app.include_router(stats_router, prefix=settings.API_V1_STR)
app.include_router(public_router, prefix=settings.API_V1_STR)

@app.get("/", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "docs": "/docs",
    }
