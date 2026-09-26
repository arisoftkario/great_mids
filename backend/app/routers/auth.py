from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, UserStatus
from app.models.audit import AuditLog
from app.schemas.auth import LoginRequest, TokenResponse
from app.schemas.user import UserResponse
from app.core.security import verify_password, create_access_token
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentification"])

@router.post("/login", response_model=TokenResponse)
def login(login_data: LoginRequest, request: Request, db: Session = Depends(get_db)):
    """Connexion sécurisée pour l'espace administration."""
    user = db.query(User).filter(User.email == login_data.email).first()
    
    ip_address = request.client.host if request.client else "unknown"
    
    if not user or not verify_password(login_data.password, user.hashed_password):
        # Enregistrer la tentative infructueuse
        if user:
            user.failed_login_attempts = (user.failed_login_attempts or 0) + 1
            db.commit()
            
        audit = AuditLog(
            user_email=login_data.email,
            action="LOGIN_FAILED",
            details="Identifiants incorrects",
            ip_address=ip_address,
        )
        db.add(audit)
        db.commit()
        
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Adresse email ou mot de passe incorrect.",
        )
        
    if user.status != UserStatus.ACTIVE:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Compte suspendu ou inactif. Veuillez contacter l'administrateur.",
        )
        
    # Réinitialiser les tentatives & mettre à jour la date de connexion
    user.failed_login_attempts = 0
    user.last_login_at = datetime.utcnow()
    
    # Audit log
    audit = AuditLog(
        user_id=user.id,
        user_email=user.email,
        action="LOGIN_SUCCESS",
        details="Connexion réussie au Back-Office",
        ip_address=ip_address,
    )
    db.add(audit)
    db.commit()
    
    # Génération du JWT
    token_payload = {
        "sub": user.id,
        "email": user.email,
        "role": user.role.value,
        "name": user.full_name,
    }
    access_token = create_access_token(token_payload)
    
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user_id=user.id,
        email=user.email,
        full_name=user.full_name,
        role=user.role,
    )

@router.get("/me", response_model=UserResponse)
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Récupère le profil de l'utilisateur actuellement connecté."""
    return current_user
